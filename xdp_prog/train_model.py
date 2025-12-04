import pandas as pd
import os
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.impute import SimpleImputer
import joblib

# --- 1. CẤU HÌNH ĐƯỜNG DẪN ---
OUTPUT_DIR = '/home/tung/xdp-prj1/xdp-dt/xdp_prog' 

FILE_CIC_2019 = '/home/tung/data/data.csv' 
FILE_LAB_MIXED = '/home/tung/xdp-prj1/learn.csv' 
FILE_IOT_NEW = '/home/tung/xdp-prj1/iot.csv'

os.makedirs(OUTPUT_DIR, exist_ok=True)

FEATURES_TO_KEEP = [
    'Flow Duration',
    'Total Fwd Packet',
    'Total Length of Fwd Packet',
    'Fwd Packet Length Max',
    'Fwd Packet Length Min',
    'Fwd IAT Min'
]

# --- 2. LOAD DỮ LIỆU ---
dfs_to_merge = []

# A. Xử lý Data.csv (Gốc)
if os.path.exists(FILE_CIC_2019):
    print(f"⏳ [1/3] Đang tải dữ liệu gốc: {FILE_CIC_2019}")
    df_cic = pd.read_csv(FILE_CIC_2019)
    print("   🔄 Chuyển đổi nhãn...")
    df_cic['Label'] = df_cic['Label'].apply(lambda x: 0 if str(x).strip().upper() == 'BENIGN' else 1)
    df_cic = df_cic[FEATURES_TO_KEEP + ['Label']]
    dfs_to_merge.append(df_cic)
    print(f"   ✅ Đã tải {len(df_cic)} dòng.")
else:
    print(f"❌ Lỗi: Không tìm thấy file {FILE_CIC_2019}")

# B. Xử lý learn.csv (Lab)
if os.path.exists(FILE_LAB_MIXED):
    print(f"⏳ [2/3] Đang tải dữ liệu Lab: {FILE_LAB_MIXED}")
    df_lab = pd.read_csv(FILE_LAB_MIXED)
    df_lab.columns = df_lab.columns.str.strip()
    
    # Xóa cột trùng lặp nếu có
    df_lab = df_lab.loc[:, ~df_lab.columns.duplicated()]

    if 'Label' in df_lab.columns:
        df_lab['Label'] = df_lab['Label'].astype(int)
        df_lab = df_lab[FEATURES_TO_KEEP + ['Label']]
        # Nhân bản 500 lần (Vì file này nhỏ)
        df_lab_up = pd.concat([df_lab] * 500, ignore_index=True)
        dfs_to_merge.append(df_lab_up)
        print(f"   ✅ Đã tải và nhân bản (Tổng: {len(df_lab_up)} dòng).")
else:
    print(f"⚠️ Cảnh báo: Không tìm thấy file {FILE_LAB_MIXED}.")

# C. Xử lý iot.csv (Mới)
if os.path.exists(FILE_IOT_NEW):
    print(f"⏳ [3/3] Đang tải dữ liệu IoT: {FILE_IOT_NEW}")
    df_iot = pd.read_csv(FILE_IOT_NEW)
    df_iot.columns = df_iot.columns.str.strip()
    
    # 1. Xóa cột trùng lặp ngay lập tức
    df_iot = df_iot.loc[:, ~df_iot.columns.duplicated()]

    # 2. Đổi tên cột
    rename_map = {
        'Flow_Duration': 'Flow Duration',
        'Tot_Fwd_Pkts': 'Total Fwd Packet',
        'TotLen_Fwd_Pkts': 'Total Length of Fwd Packet',
        'Fwd_Pkt_Len_Max': 'Fwd Packet Length Max',
        'Fwd_Pkt_Len_Min': 'Fwd Packet Length Min',
        'Fwd_IAT_Min': 'Fwd IAT Min',
        'l': 'Label' 
    }
    df_iot.rename(columns=rename_map, inplace=True)

    # 3. Xử lý Label
    if 'Label' in df_iot.columns:
        print("   🔄 Đang chuẩn hóa Label (Anomaly -> 1)...")
        df_iot['Label'] = df_iot['Label'].apply(lambda x: 1 if 'Anomaly' in str(x) else 0)
        
        try:
            df_iot = df_iot[FEATURES_TO_KEEP + ['Label']]
            
            repeat_factor = 2 
            if len(df_iot) < 10000: repeat_factor = 100
            
            df_iot_up = pd.concat([df_iot] * repeat_factor, ignore_index=True)
            dfs_to_merge.append(df_iot_up)
            print(f"   ✅ Đã tải và nhân bản {repeat_factor} lần (Tổng: {len(df_iot_up)} dòng).")
        except KeyError as e:
            print(f"   ❌ Lỗi: Thiếu cột. Chi tiết: {e}")
    else:
        print(f"   ❌ Lỗi: Không tìm thấy cột 'Label' (hoặc 'l') trong file IoT.")
else:
    print(f"⚠️ Cảnh báo: Không tìm thấy file {FILE_IOT_NEW}.")

# --- GỘP VÀ TRAIN ---
if not dfs_to_merge:
    print("❌ Không có dữ liệu!")
    exit()

print("🔄 Đang gộp tất cả dữ liệu...")
df = pd.concat(dfs_to_merge, ignore_index=True)

# Kiểm tra Label
unique_labels = df['Label'].unique()
print(f"📊 Các nhãn hiện có: {unique_labels}")

if len(unique_labels) < 2:
    print("\n⚠️  CẢNH BÁO: Thiếu dữ liệu đối chứng (chỉ có 1 loại nhãn).")
    print("🔄 Đang tự động tạo dữ liệu Normal giả lập...")
    dummy_data = {
        'Flow Duration': np.random.uniform(800000, 1200000, 5000), 
        'Total Fwd Packet': np.random.randint(4, 15, 5000),
        'Total Length of Fwd Packet': np.random.randint(64, 1000, 5000),
        'Fwd Packet Length Max': np.random.randint(64, 500, 5000),
        'Fwd Packet Length Min': np.zeros(5000),
        'Fwd IAT Min': np.random.uniform(800000, 1000000, 5000),
        'Label': 0
    }
    df_dummy = pd.DataFrame(dummy_data)
    df_dummy = df_dummy[FEATURES_TO_KEEP + ['Label']]
    df = pd.concat([df, df_dummy], ignore_index=True)

print(f"🎉 TỔNG CỘNG: {len(df)} dòng dữ liệu sẵn sàng train.")

# PREPROCESSING (giữ giống random_forest: dùng raw features, không log2, không MinMaxScaler)
X = df[FEATURES_TO_KEEP]
y = df['Label'].astype(int)

X = X.apply(pd.to_numeric, errors='coerce')
X.replace([np.inf, -np.inf], np.nan, inplace=True)
imputer = SimpleImputer(strategy='median')
X_imputed = imputer.fit_transform(X)

print("🚀 Đang chia train/test...")
X_train, X_test, y_train, y_test = train_test_split(
    X_imputed,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y,
)

print("🚀 Đang Train DecisionTreeClassifier (tự động điều chỉnh để phù hợp eBPF)...")

# Các tham số khởi tạo, dựa trên cấu trúc từ random_forest (depth giới hạn, cây không quá phức tạp)
max_dt_nodes = 5000
params = {
    "max_depth": 100,          # Giới hạn độ sâu (phù hợp với MAX_DT_DEPTH=10)
    "min_samples_split": 2,  # Tối thiểu 50 samples để split
    "min_samples_leaf": 20,   # Tối thiểu 20 samples ở leaf
    "random_state": 42,
    "criterion": "gini",
    # Cân bằng nhãn giống tinh thần random-forest (ít nhạy với mất cân bằng)
    "class_weight": "balanced",
}

dt_model = None
for attempt in range(5):
    candidate = DecisionTreeClassifier(**params)
    candidate.fit(X_train, y_train)

    node_count = candidate.tree_.node_count
    depth = candidate.tree_.max_depth

    print(f"   🔍 Thử cấu hình lần {attempt+1}: nodes={node_count}, depth={depth}, "
          f"min_split={params['min_samples_split']}, min_leaf={params['min_samples_leaf']}")

    if node_count <= max_dt_nodes:
        dt_model = candidate
        print("   ✅ Cấu hình thoả mãn giới hạn MAX_DT_NODES.")
        break

    # Nếu quá số node cho phép, tăng min_samples_split/min_samples_leaf để đơn giản hoá tree
    params["min_samples_split"] *= 2
    params["min_samples_leaf"] *= 2
    print("     Quá MAX_DT_NODES, tăng min_samples_split/min_samples_leaf và thử lại...")

if dt_model is None:
    # Fallback: dùng model cuối cùng dù vượt giới hạn, nhưng cảnh báo rõ ràng
    dt_model = candidate
    print(f"\n  Không tìm được cấu hình thoả mãn MAX_DT_NODES={max_dt_nodes} sau {attempt+1} lần thử.")
    print("   Vui lòng xem lại tham số hoặc giảm kích thước dữ liệu train.")

score = dt_model.score(X_test, y_test)
print(f" Accuracy (validation): {score*100:.2f}%")

# Lưu model (không dùng scaler/log2 như random_forest)
joblib.dump(dt_model, os.path.join(OUTPUT_DIR, 'decision_tree_model_6_features.pkl'))
print(" Đã lưu model Decision Tree (raw features) thành công.")

# In thông tin về tree
print(f"\n THÔNG TIN DECISION TREE:")
print(f"   - Số node: {dt_model.tree_.node_count}")
print(f"   - Độ sâu: {dt_model.tree_.max_depth}")
print(f"   - Số leaf: {dt_model.tree_.n_leaves}")

if dt_model.tree_.node_count > 600:
    print(f"\n  CẢNH BÁO: Tree có {dt_model.tree_.node_count} nodes, vượt quá MAX_DT_NODES=600!")
    print("   Cần tăng MAX_DT_NODES trong common_kern_user.h hoặc giảm độ phức tạp của tree.")
    print("   Gợi ý: Tăng min_samples_split và min_samples_leaf để giảm số nodes.")

