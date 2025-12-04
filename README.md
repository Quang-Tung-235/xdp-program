# XDP Decision Tree Implementation

Folder này chứa implementation riêng biệt cho Decision Tree classifier trong XDP/eBPF, được tách ra khỏi folder `xdp-program` để dễ quản lý.

## Cấu trúc

```
xdp-dt/
├── common/          # Common files (shared với xdp-program)
│   ├── common_user_bpf_xdp.c
│   ├── common_user_bpf_xdp.h
│   ├── common_params.c
│   ├── common_params.h
│   └── ...
└── xdp_prog/        # Decision Tree specific files
    ├── common_kern_user.h      # Header cho Decision Tree
    ├── xdp_prog_kern.c         # Kernel BPF code
    ├── xdp_loader.c            # Loader
    ├── train_model.py          # Training script
    ├── read_model_to_map.py    # Script load model vào BPF map
    ├── Makefile                # Build file
    └── README_DECISION_TREE.md # Hướng dẫn chi tiết
```

## Điểm khác biệt với xdp-program

- **Tách biệt hoàn toàn**: Không chia sẻ code với SVM implementation
- **Tên file đơn giản**: Bỏ suffix `_dt` vì đã tách riêng folder
- **Độc lập**: Có thể build và chạy độc lập với xdp-program

## Quick Start

### 1. Train Model

```bash
cd /home/tung/xdp-prj1/xdp-dt/xdp_prog
python3 train_model.py
```

### 2. Build

```bash
cd /home/tung/xdp-prj1/xdp-dt/xdp_prog
make
```

### 3. Load BPF Program

```bash
sudo ./xdp_loader --dev eth0 --skb-mode
```

### 4. Load Model vào Map

```bash
sudo python3 read_model_to_map.py \
    decision_tree_model_6_features.pkl \
    minmax_scaler_dt_6_features.pkl \
    /sys/fs/bpf/eth0/dt_map
```

### 5. Xem Statistics và Dump Flows

```bash
# Xem statistics
sudo ./xdp_stats eth0

# Dump flows ra CSV
sudo ./dump_map_to_csv eth0 flows.csv
```

## Chi tiết

Xem file `xdp_prog/README_DECISION_TREE.md` để biết thêm chi tiết về implementation và troubleshooting.

