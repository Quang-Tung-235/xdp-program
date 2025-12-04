/* This common_kern_user.h is used by Decision Tree kernel side BPF-progs and
 * userspace programs, for sharing common struct's and DEFINEs.
 * Based on Random Forest structure but simplified to single Decision Tree.
 */
#ifndef __COMMON_KERN_USER_H
#define __COMMON_KERN_USER_H

#include <linux/types.h>

/* Fixed-point configuration */
#define FIXED_SHIFT         16
#define FIXED_SCALE         65536
#define MAX_DT_NODES        5000  // Maximum nodes in decision tree (increased for larger trees)
#define MAX_DT_DEPTH        100   // Maximum depth of tree
#define MAX_FEATURES        6
#define MAX_FLOW_SAVED      10000

#define FEATURE_FLOW_DURATION                0
#define FEATURE_TOTAL_FWD_PACKET             1
#define FEATURE_TOTAL_LENGTH_OF_FWD_PACKET   2
#define FEATURE_FWD_PACKET_LENGTH_MAX        3
#define FEATURE_FWD_PACKET_LENGTH_MIN        4
#define FEATURE_FWD_IAT_MIN                  5

typedef __u64               fixed;

/* Flow key structure */
struct flow_key {
    __u32   src_ip;
    __u16   src_port;
    __u32   dst_ip;
    __u16   dst_port;
    __u8    proto;
} __attribute__((packed));

/* Definition of a datapoint or a flow */
typedef struct {
    __u64   start_ts;             /* Timestamp of first packet */
    __u64   last_seen;            /* Timestamp of last packet */
    __u64   min_IAT;              /* Minimum Inter-Arrival Time */
    __u32   total_pkts;           /* Total packet count */
    __u32   max_pkt_len;          /* Maximum packet length */
    __u32   min_pkt_len;          /* Minimum packet length */
    __u32   total_bytes;          /* Total byte count */
    fixed   features[MAX_FEATURES];
    int     label;
} data_point;

/* Latency statistics structure */
typedef struct {
    __u64 time_in;
    __u64 proc_time;  /*proc_time += time_out - time_in*/
    __u32 total_pkts;
    __u32 total_bytes;
} accounting;

/* Definition of a Node in Decision Tree */
typedef struct {
    int     left_idx;        // Index of left child (-1 if no child)
    int     right_idx;       // Index of right child (-1 if no child)
    fixed   split_value;     // Threshold value for splitting
    int     feature_idx;     // Which feature to check (0-5)
    __u32   is_leaf;         // 1 if leaf node, 0 otherwise
    int     label;           // Class label if leaf (0=Normal, 1=Anomaly)
} dt_node;

/* Decision Tree structure with scaler info */
typedef struct {
    dt_node nodes[MAX_DT_NODES];
    __u32   num_nodes;       // Actual number of nodes in tree
    fixed   min_vals[MAX_FEATURES];  // Min values for normalization
    fixed   max_vals[MAX_FEATURES];  // Max values for normalization
} dt_tree;

/* Convert float (as double in user space) to fixed-point */
static __always_inline fixed fixed_from_float(double value)
{
    return (__u64)(value * (double)FIXED_SCALE);
}

/* Convert fixed-point to float */
static __always_inline double fixed_to_float(fixed value)
{
    return (double)value / (double)FIXED_SCALE;
}

/* Convert unsigned integer to fixed-point */
static __always_inline fixed fixed_from_uint(__u64 value)
{
    return value << FIXED_SHIFT;
}

/* Convert fixed-point to integer (truncate fractional) */
static __always_inline __u64 fixed_to_uint(fixed value)
{
    return value >> FIXED_SHIFT;
}

/* Add two fixed-point values */
static __always_inline fixed fixed_add(fixed a, fixed b)
{
    return a + b;
}

/* Subtract two fixed-point values (with underflow protection) */
static __always_inline fixed fixed_sub(fixed a, fixed b)
{
    return (a > b) ? (a - b) : 0;
}

/* Multiply two fixed-point values (with scale correction) */
static __always_inline fixed fixed_mul(fixed a, fixed b)
{
    __u64 a_int = a >> FIXED_SHIFT;
    __u64 a_frac = a & ((1ULL << FIXED_SHIFT) - 1);
    __u64 b_int = b >> FIXED_SHIFT;
    __u64 b_frac = b & ((1ULL << FIXED_SHIFT) - 1);
    
    __u64 result_int = a_int * b_int;
    __u64 result_frac = (a_int * b_frac + a_frac * b_int) >> FIXED_SHIFT;
    __u64 result_frac_frac = (a_frac * b_frac) >> (FIXED_SHIFT * 2);
    
    return (result_int << FIXED_SHIFT) + result_frac + result_frac_frac;
}

/* Divide two fixed-point values */
static __always_inline fixed fixed_div(fixed a, fixed b)
{
    if (b == 0)
        return 0;
    
    /* Shift dividend left to maintain precision: (a * FIXED_SCALE) / b */
    /* Use unsigned division (eBPF doesn't support signed division) */
    __u64 shifted_a = a << FIXED_SHIFT;
    return shifted_a / b;
}

/* Fixed-point log2 approximation: calculates log2(x) */
static __always_inline fixed fixed_log2(__u64 x)
{
    if (x == 0)
        return 0;  // log2(0) = -inf, but we return 0 to avoid issues

    __u64 int_part = 0;
    __u64 tmp = x;
    
    while (tmp >>= 1)
        int_part++;

    __u64 base = 1ULL << int_part;
    __u64 remainder = x - base;
    __u64 frac = (remainder << FIXED_SHIFT) / base;
    
    return (int_part << FIXED_SHIFT) | frac;
}

#ifndef XDP_ACTION_MAX
#define XDP_ACTION_MAX (XDP_REDIRECT + 1)
#endif

#endif /* __COMMON_KERN_USER_H */

