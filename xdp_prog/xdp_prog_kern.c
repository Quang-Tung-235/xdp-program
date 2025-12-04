// File: xdp_prog_kern.c
// BPF kernel code for Decision Tree classification. Uses dt_map for classification.

// SPDX-License-Identifier: GPL-2.0
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/udp.h>
#include <linux/tcp.h>
#include <linux/icmp.h>
#include <linux/in.h>
#include <bpf/bpf_endian.h>
#include "common_kern_user.h"

#define NANOSEC_PER_SEC 1000000000ULL

#ifndef lock_xadd
#define lock_xadd(ptr, val) ((void)__sync_fetch_and_add((ptr), (val)))
#endif

/* ================= MAPS ================= */
struct {
    __uint(type, BPF_MAP_TYPE_ARRAY);
    __uint(max_entries, 1);
    __type(key, __u32);
    __type(value, dt_tree);
    // __uint(pinning, LIBBPF_PIN_BY_NAME);
} dt_map SEC(".maps");

// Flow tracking
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __type(key, struct flow_key);
    __type(value, data_point);
    __uint(max_entries, MAX_FLOW_SAVED);
    // __uint(pinning, LIBBPF_PIN_BY_NAME);
} xdp_flow_tracking SEC(".maps");

struct {
    __uint(type, BPF_MAP_TYPE_ARRAY);
    __type(key, __u32);
    __type(value, accounting);
    __uint(max_entries, 1);
    // __uint(pinning, LIBBPF_PIN_BY_NAME);
} accounting_map SEC(".maps");

/* ================= PACKET PARSING ================= */
static __always_inline int parse_packet_get_data(struct xdp_md *ctx,
                                                 struct flow_key *key,
                                                 __u64 *pkt_len)
{
    void *data_end = (void *)(long)ctx->data_end;
    void *data     = (void *)(long)ctx->data;
    struct ethhdr *eth = data;

    if ((void *)(eth + 1) > data_end)
        return -1;

    if (eth->h_proto == bpf_htons(0x88cc))
        return -2; // drop LLDP

    if (eth->h_proto != bpf_htons(ETH_P_IP))
        return -1;

    struct iphdr *iph = (struct iphdr *)(eth + 1);
    if ((void *)(iph + 1) > data_end)
        return -1;

    key->src_ip = iph->saddr;
    key->dst_ip = iph->daddr;
    key->proto  = iph->protocol;

    if (iph->protocol == IPPROTO_ICMP) {
        struct icmphdr *icmp = (struct icmphdr *)((__u8 *)iph + (iph->ihl * 4));
        if ((void *)(icmp + 1) > data_end)
            return -1;
        __u32 src = bpf_ntohl(iph->saddr);
        __u32 dst = bpf_ntohl(iph->daddr);
        if ((src == 0xC0A83203 && dst == 0xC0A83204 && icmp->type == 8) ||
            (src == 0xC0A83204 && dst == 0xC0A83203 && icmp->type == 0)) {
            return 1;
        }
    }

    if (iph->protocol == IPPROTO_TCP) {
        struct tcphdr *tcph = (struct tcphdr *)((__u8 *)iph + (iph->ihl * 4));
        if ((void *)(tcph + 1) > data_end) return -1;
        key->src_port = tcph->source;
        key->dst_port = tcph->dest;
    } else if (iph->protocol == IPPROTO_UDP) {
        struct udphdr *udph = (struct udphdr *)((__u8 *)iph + (iph->ihl * 4));
        if ((void *)(udph + 1) > data_end) return -1;
        key->src_port = udph->source;
        key->dst_port = udph->dest;
    } else {
        key->src_port = 0;
        key->dst_port = 0;
    }

    key->src_port = bpf_ntohs(key->src_port);
    key->dst_port = bpf_ntohs(key->dst_port);
    *pkt_len = (__u64)((__u8 *)data_end - (__u8 *)data);
    return 0;
}

/* ================= DECISION TREE INFERENCE ================= */
static __always_inline int predict_dt(data_point *dp, const dt_tree *tree)
{
    if (!tree || tree->num_nodes == 0)
        return 0;  // Default to Normal if tree not loaded
    
    __u32 node_idx = 0;  // Start from root (index 0)
    
    // Traverse tree from root to leaf
    for (int depth = 0; depth < MAX_DT_DEPTH; depth++) {
        if (node_idx >= tree->num_nodes || node_idx >= MAX_DT_NODES)
            return 0;  // Out of bounds, default to Normal
        
        const dt_node *node = &tree->nodes[node_idx];
        
        // If leaf node, return its label
        if (node->is_leaf) {
            return node->label;
        }
        
        // Internal node: check feature value against threshold (raw fixed-point, không scaler)
        if (node->feature_idx < 0 || node->feature_idx >= MAX_FEATURES)
            return 0;  // Invalid feature index
        
        // Get raw feature value (đã là fixed_from_uint ở update_stats)
        fixed raw_feat = dp->features[node->feature_idx];
        
        // Compare with split threshold (cùng đơn vị raw feature như khi train)
        if (raw_feat <= node->split_value) {
            // Go to left child
            if (node->left_idx < 0 || node->left_idx >= MAX_DT_NODES)
                return 0;
            node_idx = (__u32)node->left_idx;
        } else {
            // Go to right child
            if (node->right_idx < 0 || node->right_idx >= MAX_DT_NODES)
                return 0;
            node_idx = (__u32)node->right_idx;
        }
    }
    
    // Reached max depth without finding leaf, default to Normal
    return 0;
}

/* ================= FLOW STATS ================= */
static __always_inline int update_stats(struct flow_key *key,
                                        struct xdp_md *ctx)
{
    __u64 ts_ns = bpf_ktime_get_ns();
    __u64 pkt_len = (__u64)((__u8 *)((void *)(long)ctx->data_end) - 
                            (__u8 *)((void *)(long)ctx->data));
    int ret = XDP_PASS;
    int is_new_flow = 0;

    data_point *dp = bpf_map_lookup_elem(&xdp_flow_tracking, key);
    if (!dp) {
        // Create new flow entry
        data_point zero = {};
        zero.start_ts = ts_ns;
        zero.last_seen = ts_ns;
        zero.min_IAT = 0xFFFFFFFFFFFFFFFFULL;
        zero.total_pkts = 1;
        zero.max_pkt_len = pkt_len;
        zero.min_pkt_len = pkt_len;
        zero.total_bytes = pkt_len;
        zero.label = 0;
        // Initialize features to 0
        for (int i = 0; i < MAX_FEATURES; i++) {
            zero.features[i] = 0;
        }
        
        if (bpf_map_update_elem(&xdp_flow_tracking, key, &zero, BPF_ANY) != 0){
            return ret;
        }
        
        // Lookup again to get pointer for classification
        dp = bpf_map_lookup_elem(&xdp_flow_tracking, key);
        if (!dp) {
            return ret;
        }
        is_new_flow = 1;
    }

    if (!is_new_flow) {
        __u64 iat_ns = (dp->last_seen > 0 && ts_ns >= dp->last_seen) ? ts_ns - dp->last_seen : 0;
        __sync_fetch_and_add(&dp->total_pkts, 1);
        __sync_fetch_and_add(&dp->total_bytes, pkt_len);

        if (iat_ns > 0 && iat_ns < dp->min_IAT)
            dp->min_IAT = iat_ns;

        if (pkt_len > dp->max_pkt_len)
            dp->max_pkt_len = pkt_len;

        if (pkt_len < dp->min_pkt_len)
            dp->min_pkt_len = pkt_len;
    }

    dp->last_seen = ts_ns;
    
    // Calculate features giống random_forest: dùng raw value, không log2 / scaler
    __u64 duration_us = (dp->last_seen - dp->start_ts) / 1000;
    dp->features[FEATURE_FLOW_DURATION] = fixed_from_uint(duration_us);
    dp->features[FEATURE_TOTAL_FWD_PACKET] = fixed_from_uint(dp->total_pkts);
    dp->features[FEATURE_TOTAL_LENGTH_OF_FWD_PACKET] = fixed_from_uint(dp->total_bytes);
    dp->features[FEATURE_FWD_PACKET_LENGTH_MAX] = fixed_from_uint(dp->max_pkt_len);
    dp->features[FEATURE_FWD_PACKET_LENGTH_MIN] = fixed_from_uint(dp->min_pkt_len);
    __u64 iat_us = (dp->min_IAT != 0xFFFFFFFFFFFFFFFFULL) ? (dp->min_IAT / 1000) : 0;
    dp->features[FEATURE_FWD_IAT_MIN] = fixed_from_uint(iat_us);
    
    // Get Decision Tree parameters
    __u32 key_dt = 0;
    dt_tree *dt_pr = bpf_map_lookup_elem(&dt_map, &key_dt); 

    // Classify using Decision Tree
    if (dt_pr) {
        int dt_pred = predict_dt(dp, dt_pr);
        dp->label = dt_pred;  // 0 = Normal, 1 = Anomaly
    } else {
        // Model not loaded, default to normal
        dp->label = 0;
    }
    
    // Update map with latest data
    if(bpf_map_update_elem(&xdp_flow_tracking, key, dp, BPF_ANY) != 0){
        return ret;
    }

    return ret;
}

/* ================= XDP ENTRY ================= */
SEC("xdp")
int xdp_anomaly_detector(struct xdp_md *ctx)
{
    struct flow_key key = {};
    __u64 pkt_len = 0;
    __u32 key_ac = 0;
    
    // Parse packet first
    int ret = parse_packet_get_data(ctx, &key, &pkt_len);
    if (ret == -2)
        return XDP_DROP;  // drop LLDP
    if (ret < 0)
        return XDP_PASS;  // Invalid packet, pass through
    
    // ret == 0: Normal IP packet (TCP/UDP/ICMP)
    // ret == 1: Special ICMP packet (still track it)
    // Update flow stats for all valid IP packets
    ret = update_stats(&key, ctx);

    // Update accounting if map is available (optional, for statistics)
    accounting *ac;
    ac = bpf_map_lookup_elem(&accounting_map, &key_ac);
    if (ac) {
        __u64 time_out = bpf_ktime_get_ns();
        ac->proc_time += time_out - ac->time_in;
        ac->total_bytes += pkt_len;
        ac->total_pkts += 1;
        bpf_map_update_elem(&accounting_map, &key_ac, ac, BPF_ANY);
    }

    return ret;
}

char _license[] SEC("license") = "GPL";

