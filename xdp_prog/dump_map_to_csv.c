#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <bpf/bpf.h>
#include <bpf/libbpf.h>
#include <arpa/inet.h>
#include <netinet/in.h>

// Include header của tutorial để dùng lại hàm open_bpf_map_file có sẵn
#include "../common/common_params.h"
#include "../common/common_user_bpf_xdp.h" 
#include "common_kern_user.h"

const char *pin_basedir = "/sys/fs/bpf";

// Hàm in dòng CSV (Giữ nguyên)
static void print_flow_csv(FILE *f, const struct flow_key *key, const data_point *dp) {
    char src_ip[INET_ADDRSTRLEN];
    char dst_ip[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, &key->src_ip, src_ip, sizeof(src_ip));
    inet_ntop(AF_INET, &key->dst_ip, dst_ip, sizeof(dst_ip));

    // Chuyển đổi Fixed-point sang Float
    double feat0 = fixed_to_float(dp->features[0]);
    double feat1 = fixed_to_float(dp->features[1]);
    double feat2 = fixed_to_float(dp->features[2]);
    double feat3 = fixed_to_float(dp->features[3]);
    double feat4 = fixed_to_float(dp->features[4]);
    double feat5 = fixed_to_float(dp->features[5]);

    fprintf(f, "%s,%u,%s,%u,%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%d\n",
            src_ip, key->src_port,
            dst_ip, key->dst_port,
            key->proto,
            feat0, feat1, feat2, feat3, feat4, feat5,
            dp->label);
}

// Hàm duyệt toàn bộ map
static void dump_flow_map_to_csv(int map_fd, FILE *f) {
    struct flow_key key, next_key;
    data_point dp;
    
    // Header CSV
    fprintf(f, "SrcIP,SrcPort,DstIP,DstPort,Proto,FlowDur,TotalPkts,TotalBytes,MaxLen,MinLen,IAT_min,Label\n");

    memset(&key, 0, sizeof(key));

    while (bpf_map_get_next_key(map_fd, &key, &next_key) == 0) {
        if (bpf_map_lookup_elem(map_fd, &next_key, &dp) == 0) {
            print_flow_csv(f, &next_key, &dp);
        }
        key = next_key;
    }
    fflush(f);
}

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <ifname> <output.csv>\n", argv[0]);
        return 1;
    }

    const char *ifname = argv[1];
    const char *filename = argv[2];
    
    // Build map path using interface name
    char map_path[4096];
    snprintf(map_path, sizeof(map_path), "%s/%s/xdp_flow_tracking", pin_basedir, ifname);
    
    // Check if map file exists
    if (access(map_path, F_OK) != 0) {
        fprintf(stderr, "Error: Cannot find xdp_flow_tracking map at %s\n", map_path);
        fprintf(stderr, "   File does not exist (errno: %d - %s)\n", errno, strerror(errno));
        fprintf(stderr, "   Try: sudo ls -la %s/%s/\n", pin_basedir, ifname);
        fprintf(stderr, "   Or: sudo bpftool map show\n");
        return 1;
    }
    
    int fd = bpf_obj_get(map_path);
    if (fd < 0) {
        fprintf(stderr, "Error: Cannot open xdp_flow_tracking map at %s\n", map_path);
        fprintf(stderr, "   bpf_obj_get failed (errno: %d - %s)\n", errno, strerror(errno));
        fprintf(stderr, "   Try: sudo bpftool map show\n");
        return 1;
    }

    FILE *f = fopen(filename, "w");
    if (!f) {
        perror("fopen");
        close(fd);
        return 1;
    }

    dump_flow_map_to_csv(fd, f);
    fclose(f);
    close(fd);

    printf("Success: Exported flow data to %s\n", filename);
    return 0;
}