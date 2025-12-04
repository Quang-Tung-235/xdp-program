import joblib
from bcc import BPF, libbcc
import ctypes
import os
import sys
import numpy as np

# --- CẤU HÌNH ---
# Phải khớp với common_kern_user.h
FIXED_SHIFT = 16
FIXED_SCALE = 1 << FIXED_SHIFT
MAX_FEATURES = 6
MAX_DT_NODES = 600

class Fixed(ctypes.c_uint64):
    pass

class DTNode(ctypes.Structure):
    _fields_ = [
        ("left_idx", ctypes.c_int),
        ("right_idx", ctypes.c_int),
        ("split_value", Fixed),
        ("feature_idx", ctypes.c_int),
        ("is_leaf", ctypes.c_uint32),
        ("label", ctypes.c_int),
    ]

class DTTree(ctypes.Structure):
    _fields_ = [
        ("nodes", DTNode * MAX_DT_NODES),
        ("num_nodes", ctypes.c_uint32),
        ("min_vals", Fixed * MAX_FEATURES),
        ("max_vals", Fixed * MAX_FEATURES),
    ]

def fixed_from_float(value: float) -> int:
    """
    Chuyển float sang fixed-point Q48.16 (unsigned) giống random_forest: threshold huấn luyện trên raw features.
    """
    scaled = int(round(value * FIXED_SCALE))
    if scaled < 0:
        scaled = 0
    return ctypes.c_uint64(scaled).value

def load_dt_model(model_path):
    print(f"⏳ Loading Decision Tree model from {model_path}...")
    model = joblib.load(model_path)
    if not hasattr(model, 'tree_'):
        raise ValueError("Not a valid Decision Tree model")
    
    tree = model.tree_
    print(f"   ✅ Tree nodes: {tree.node_count}")
    print(f"   ✅ Tree depth: {tree.max_depth}")
    print(f"   ✅ Tree leaves: {tree.n_leaves}")
    
    if tree.node_count > MAX_DT_NODES:
        raise ValueError(f"Tree has {tree.node_count} nodes, exceeds MAX_DT_NODES={MAX_DT_NODES}")
    
    return model, tree

def convert_tree_to_nodes(tree, dt_tree_struct):
    """Convert sklearn tree to our DTNode structure (raw feature thresholds, không scaler)."""
    node_count = tree.node_count
    
    # Initialize all nodes
    for i in range(MAX_DT_NODES):
        dt_tree_struct.nodes[i].left_idx = -1
        dt_tree_struct.nodes[i].right_idx = -1
        dt_tree_struct.nodes[i].split_value = 0
        dt_tree_struct.nodes[i].feature_idx = -1
        dt_tree_struct.nodes[i].is_leaf = 1
        dt_tree_struct.nodes[i].label = 0
    
    # Convert sklearn tree structure to our format
    for i in range(node_count):
        left_child = tree.children_left[i]
        right_child = tree.children_right[i]
        feature = tree.feature[i]
        threshold = tree.threshold[i]
        
        # Check if leaf node
        is_leaf = (left_child == right_child)  # same index for both children if leaf
        
        if is_leaf:
            # Leaf node: majority class
            value = tree.value[i]
            label = int(np.argmax(value[0]))
            dt_tree_struct.nodes[i].is_leaf = 1
            dt_tree_struct.nodes[i].label = label
            dt_tree_struct.nodes[i].left_idx = -1
            dt_tree_struct.nodes[i].right_idx = -1
            dt_tree_struct.nodes[i].feature_idx = -1
            dt_tree_struct.nodes[i].split_value = 0
        else:
            # Internal node
            dt_tree_struct.nodes[i].is_leaf = 0
            dt_tree_struct.nodes[i].left_idx = left_child
            dt_tree_struct.nodes[i].right_idx = right_child
            dt_tree_struct.nodes[i].feature_idx = feature
            # Convert threshold (raw feature space) to fixed-point
            dt_tree_struct.nodes[i].split_value = fixed_from_float(float(threshold))
            dt_tree_struct.nodes[i].label = -1  # not used for internal nodes
    
    dt_tree_struct.num_nodes = node_count
    print(f"   ✅ Converted {node_count} nodes to DTNode structure")

def update_bpf_map(map_path, model, tree):
    print(f"🔄 Updating BPF Map at: {map_path}")
    
    # Hack: Truyền text rỗng để lừa thư viện bcc không cần biên dịch C
    bpf = BPF(text=b"") 
    map_fd = libbcc.lib.bpf_obj_get(map_path.encode())
    if map_fd < 0:
        raise IOError(f"Failed to open BPF map at {map_path}")

    dt_tree = DTTree()
    
    # 1. Convert tree to nodes (min/max không dùng, giữ mặc định 0)
    convert_tree_to_nodes(tree, dt_tree)
    
    # 2. Ghi vào Map (Key 0)
    key = ctypes.c_uint32(0)
    ret = libbcc.lib.bpf_update_elem(map_fd, ctypes.byref(key), ctypes.byref(dt_tree), 0)
    if ret != 0:
        raise IOError("Failed to update BPF map via LibBCC")
    
    print("🎉 Successfully updated Decision Tree map!")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 read_model_to_map_dt.py <model.pkl> <map_path>")
        print("Example: python3 read_model_to_map_dt.py decision_tree_model_6_features.pkl /sys/fs/bpf/eth0/dt_map")
        sys.exit(1)
    
    model_path = sys.argv[1]
    map_path = sys.argv[2]
    
    # Load dữ liệu
    model, tree = load_dt_model(model_path)
    
    # Update Map
    update_bpf_map(map_path, model, tree)

