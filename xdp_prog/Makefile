#SPDX-License-Identifier: (GPL-2.0 OR BSD-2-Clause)

# Decision Tree targets
XDP_TARGETS := xdp_prog_kern
USER_TARGETS := xdp_loader
USER_TARGETS += xdp_stats
USER_TARGETS += dump_map_to_csv

COMMON_DIR := ../common

COMMON_OBJS := $(COMMON_DIR)/common_user_bpf_xdp.o

include $(COMMON_DIR)/common.mk

LDLIBS += -lxdp
CFLAGS += -I/usr/local/include
LDFLAGS += -L/usr/local/lib
LDLIBS += -l:libxdp.a -l:libbpf.a -lelf -lz -lm
# Override BPF_CFLAGS to include correct paths
BPF_CFLAGS += -I../../xdp-program/lib/libbpf/include/uapi \
              -I../../xdp-program/lib/xdp-tools/headers \
              -I../common \
              -I.

.PHONY: all clean

all: $(XDP_TARGETS:=.o) $(USER_TARGETS)

clean:
	rm -f $(XDP_TARGETS:=.o) $(XDP_TARGETS:=.ll) $(USER_TARGETS) *.ll


