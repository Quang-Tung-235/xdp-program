# Decision Tree Implementation cho XDP DDoS Detection

## Tổng quan

Folder `xdp-dt` triển khai Decision Tree classifier cho phát hiện DDoS attack trong eBPF/XDP. Implementation này được tách riêng hoàn toàn khỏi folder `xdp-program` để dễ quản lý.

## Cấu trúc Files

### Files trong folder xdp-dt:
- `common_kern_user.h`: Header file cho Decision Tree
- `xdp_prog_kern.c`: Kernel BPF code cho Decision Tree
- `xdp_loader.c`: Loader cho Decision Tree
- `train_model.py`: Script để train Decision Tree model
- `read_model_to_map.py`: Script để load Decision Tree vào BPF map
- `Makefile`: Build file cho Decision Tree
- `README_DECISION_TREE.md`: File hướng dẫn này

## Workflow sử dụng

### Bước 1: Train Decision Tree Model

```bash
cd /home/tung/xdp-prj1/xdp-dt/xdp_prog
python3 train_model.py
```

Script này sẽ:
- Load dữ liệu từ các file CSV (data.csv, learn.csv, iot.csv) - **cùng dữ liệu như SVM**
- Preprocess dữ liệu (log2, MinMax scaling) - **giống hệt SVM**
- Train Decision Tree với các tham số tối ưu cho eBPF
- Lưu model vào `decision_tree_model_6_features.pkl`
- Lưu scaler vào `minmax_scaler_dt_6_features.pkl`

**Lưu ý**: Model sẽ được train với:
- `max_depth=10`: Giới hạn độ sâu (phù hợp với MAX_DT_DEPTH=10)
- `min_samples_split=50`: Tối thiểu 50 samples để split
- `min_samples_leaf=20`: Tối thiểu 20 samples ở leaf

### Bước 2: Compile BPF Program

```bash
cd /home/tung/xdp-prj1/xdp-dt/xdp_prog
make
```

Sau khi build, bạn sẽ có:
- `xdp_prog_kern.o`: BPF object file cho Decision Tree
- `xdp_loader`: Loader executable cho Decision Tree

### Bước 3: Load BPF Program vào Interface

```bash
sudo ./xdp_loader --dev <interface> --skb-mode
# Ví dụ: sudo ./xdp_loader --dev eth0 --skb-mode
```

Sau khi load, map sẽ được pin tại:
- `/sys/fs/bpf/<interface>/xdp_flow_tracking`
- `/sys/fs/bpf/<interface>/dt_map`

### Bước 4: Load Decision Tree Model vào BPF Map

```bash
sudo python3 read_model_to_map.py \
    decision_tree_model_6_features.pkl \
    minmax_scaler_dt_6_features.pkl \
    /sys/fs/bpf/<interface>/dt_map
```

**Ví dụ**:
```bash
sudo python3 read_model_to_map.py \
    decision_tree_model_6_features.pkl \
    minmax_scaler_dt_6_features.pkl \
    /sys/fs/bpf/eth0/dt_map
```

### Bước 5: Kiểm tra kết quả

#### Xem statistics:
```bash
sudo ./xdp_stats <interface>
# Ví dụ: sudo ./xdp_stats eth0
```

#### Dump flows ra CSV:
```bash
sudo ./dump_map_to_csv <interface> <output.csv>
# Ví dụ: sudo ./dump_map_to_csv eth0 flows.csv
```

## So sánh với SVM

### Ưu điểm của Decision Tree:
1. **Dễ hiểu**: Logic phân loại rõ ràng, có thể visualize
2. **Không cần threshold tuning**: Trực tiếp trả về class (0 hoặc 1)
3. **Xử lý non-linear tốt hơn**: Có thể capture các pattern phức tạp

### Nhược điểm:
1. **Kích thước lớn hơn**: Cần lưu nhiều node (tối đa 600 nodes)
2. **Có thể overfit**: Nếu tree quá sâu
3. **Phụ thuộc vào cấu trúc**: Cần đảm bảo tree không vượt quá MAX_DT_NODES (600)

## Cấu trúc Decision Tree trong eBPF

### Node Structure (`dt_node`):
```c
typedef struct {
    int     left_idx;        // Index của left child (-1 nếu không có)
    int     right_idx;       // Index của right child (-1 nếu không có)
    fixed   split_value;     // Giá trị threshold để split
    int     feature_idx;     // Feature nào để check (0-5)
    __u32   is_leaf;         // 1 nếu là leaf, 0 nếu internal node
    int     label;           // Class label nếu là leaf (0=Normal, 1=Anomaly)
} dt_node;
```

### Tree Structure (`dt_tree`):
```c
typedef struct {
    dt_node nodes[MAX_DT_NODES];      // Mảng các node
    __u32   num_nodes;                // Số node thực tế
    fixed   min_vals[MAX_FEATURES];    // Min values cho normalization
    fixed   max_vals[MAX_FEATURES];    // Max values cho normalization
} dt_tree;
```

## Prediction Logic

1. Bắt đầu từ root node (index 0)
2. Kiểm tra xem node có phải leaf không:
   - Nếu là leaf: trả về `label` của node
   - Nếu không: tiếp tục
3. Lấy feature value tại `feature_idx` và normalize
4. So sánh với `split_value`:
   - Nếu `feature <= split_value`: đi sang left child
   - Nếu `feature > split_value`: đi sang right child
5. Lặp lại cho đến khi gặp leaf hoặc đạt MAX_DT_DEPTH

## Troubleshooting

### Lỗi: "Tree has X nodes, exceeds MAX_DT_NODES=600"
**Giải pháp**: 
- Tăng `MAX_DT_NODES` trong `common_kern_user.h` (hiện tại là 600)
- Hoặc giảm độ phức tạp của tree bằng cách tăng `min_samples_split` và `min_samples_leaf` trong `train_model.py`
- Ví dụ: `min_samples_split=200, min_samples_leaf=100` sẽ tạo tree nhỏ hơn

### Lỗi: "Failed to open BPF map"
**Giải pháp**:
- Đảm bảo đã load BPF program trước (`xdp_loader`)
- Kiểm tra đường dẫn map có đúng không
- Kiểm tra quyền sudo

### Model không hoạt động đúng
**Giải pháp**:
- Kiểm tra lại model đã được load vào map chưa
- Xem log kernel: `sudo dmesg | tail -50`
- Kiểm tra lại preprocessing (log2, scaling) có khớp với training không

## Git Commands

### Chuyển giữa các branch:
```bash
git checkout svm              # Chuyển sang branch SVM
git checkout decision-tree     # Chuyển sang branch Decision Tree
git checkout random_forest     # Chuyển sang branch Random Forest
```

### So sánh với branch khác:
```bash
git diff svm                  # So sánh với SVM
git diff origin/random_forest  # So sánh với RF
```

## Lưu ý quan trọng

- **Tách biệt hoàn toàn**: Tất cả code Decision Tree nằm trong folder `xdp-dt`, không ảnh hưởng đến `xdp-program`
- **Có thể chạy song song**: Có thể build và test cả SVM và Decision Tree trên cùng một máy (khác interface)
- **Dùng chung dữ liệu**: Cùng CSV files và preprocessing như SVM
- **Tên file đơn giản**: Bỏ suffix `_dt` vì đã tách riêng folder

