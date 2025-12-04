// File: xdp_stats.c
// Display statistics from accounting_map
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <time.h>
#include <bpf/bpf.h>
#include <bpf/libbpf.h>
#include "../common/common_user_bpf_xdp.h"
#include "common_kern_user.h"

const char *pin_basedir = "/sys/fs/bpf";

static void print_stats(const accounting *ac) {
    double proc_time_ms = (double)ac->proc_time / 1000000.0; // Convert ns to ms
    double proc_time_s = proc_time_ms / 1000.0; // Convert ms to s
    
    printf("\n=== XDP Decision Tree Statistics ===\n");
    printf("Total Packets Processed: %u\n", ac->total_pkts);
    printf("Total Bytes Processed: %llu\n", (unsigned long long)ac->total_bytes);
    printf("Total Processing Time: %.3f ms (%.6f s)\n", proc_time_ms, proc_time_s);
    
    if (ac->total_pkts > 0) {
        double avg_time_per_pkt = proc_time_ms / (double)ac->total_pkts;
        double throughput_mbps = ((double)ac->total_bytes * 8.0) / (proc_time_s * 1000000.0);
        printf("Average Time per Packet: %.6f ms\n", avg_time_per_pkt);
        printf("Throughput: %.2f Mbps\n", throughput_mbps);
    }
    printf("=====================================\n\n");
}

int main(int argc, char **argv) {
    const char *ifname;
    
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <ifname>\n", argv[0]);
        fprintf(stderr, "Example: %s eth0\n", argv[0]);
        return 1;
    }
    
    ifname = argv[1];
    
    char pin_dir[4096];
    snprintf(pin_dir, sizeof(pin_dir), "%s/%s", pin_basedir, ifname);
    
    struct bpf_map_info info = {0};
    int fd = open_bpf_map_file(pin_dir, "accounting_map", &info);
    if (fd < 0) {
        fprintf(stderr, "Error: Cannot find accounting_map at %s/accounting_map\n", pin_dir);
        fprintf(stderr, "Make sure XDP program is loaded on interface %s\n", ifname);
        return 1;
    }
    
    __u32 key = 0;
    accounting ac;
    
    if (bpf_map_lookup_elem(fd, &key, &ac) != 0) {
        perror("bpf_map_lookup_elem");
        close(fd);
        return 1;
    }
    
    print_stats(&ac);
    close(fd);
    
    return 0;
}
