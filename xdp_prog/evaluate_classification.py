#!/usr/bin/env python3
"""
Evaluate classification results for Decision Tree - calculate accuracy, precision, recall, F1
Can test with CSV files or compare kernel output with sklearn predictions
"""
import joblib
import numpy as np
import pandas as pd
import sys
import os

# Get script directory to find model files
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Try to load model from script directory (raw features, không scaler)
MODEL_PATH = os.path.join(SCRIPT_DIR, 'decision_tree_model_6_features.pkl')

if not os.path.exists(MODEL_PATH):
    print(f"⚠️  Warning: Model file not found at {MODEL_PATH}")
    print("   Trying current directory...")
    MODEL_PATH = 'decision_tree_model_6_features.pkl'

try:
    model = joblib.load(MODEL_PATH)
    print(f"✅ Loaded model from: {MODEL_PATH}")
except Exception as e:
    print(f"❌ Error loading model: {e}")
    print("   Make sure train_model.py has been run first")
    sys.exit(1)

def calculate_metrics(y_true, y_pred):
    """Calculate classification metrics"""
    tp = sum(1 for i in range(len(y_true)) if y_true[i] == 1 and y_pred[i] == 1)
    tn = sum(1 for i in range(len(y_true)) if y_true[i] == 0 and y_pred[i] == 0)
    fp = sum(1 for i in range(len(y_true)) if y_true[i] == 0 and y_pred[i] == 1)
    fn = sum(1 for i in range(len(y_true)) if y_true[i] == 1 and y_pred[i] == 0)
    
    accuracy = (tp + tn) / len(y_true) if len(y_true) > 0 else 0
    precision = tp / (tp + fp) if (tp + fp) > 0 else 0
    recall = tp / (tp + fn) if (tp + fn) > 0 else 0
    f1 = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
    
    return {
        'tp': tp, 'tn': tn, 'fp': fp, 'fn': fn,
        'accuracy': accuracy, 'precision': precision, 'recall': recall, 'f1': f1
    }

def analyze_csv(csv_file, expected_labels=None, ground_truth_mode='sklearn'):
    """Analyze CSV file and compare with sklearn predictions
    
    Args:
        csv_file: Path to CSV file with flow data
        expected_labels: Optional CSV file with expected labels (for ground_truth_mode='file')
        ground_truth_mode: 'sklearn', 'filename', or 'file'
    """
    if not os.path.exists(csv_file):
        print(f"❌ File not found: {csv_file}")
        return None
    
    df = pd.read_csv(csv_file)
    
    if len(df) == 0:
        print("❌ CSV file is empty")
        return None
    
    features_cols = ['FlowDur', 'TotalPkts', 'TotalBytes', 'MaxLen', 'MinLen', 'IAT_min']
    
    # Check if all required columns exist
    missing_cols = [col for col in features_cols if col not in df.columns]
    if missing_cols:
        print(f"❌ Missing columns in CSV: {missing_cols}")
        return None
    
    features = df[features_cols].values
    
    # Calculate sklearn predictions (model huấn luyện trên raw features, không scaler)
    predictions_sklearn = model.predict(features)
    probabilities_sklearn = model.predict_proba(features)
    
    df['Prediction_Sklearn'] = predictions_sklearn
    df['Probability_Normal'] = probabilities_sklearn[:, 0]
    df['Probability_Attack'] = probabilities_sklearn[:, 1]
    df['Prediction_Kernel'] = df['Label']  # Kernel prediction from CSV
    
    # Determine ground truth based on mode
    if ground_truth_mode == 'filename':
        # Auto-detect from filename
        csv_basename = os.path.basename(csv_file).lower()
        if 'attack' in csv_basename:
            y_true = np.ones(len(df), dtype=int)
            print("   📌 Detected 'attack' in filename, using all labels as Attack (1)")
        elif 'benign' in csv_basename or 'normal' in csv_basename:
            y_true = np.zeros(len(df), dtype=int)
            print("   📌 Detected 'benign/normal' in filename, using all labels as Normal (0)")
        else:
            print("   ⚠️  Warning: Cannot determine ground truth from filename. Using sklearn predictions.")
            y_true = predictions_sklearn
    elif ground_truth_mode == 'file' and expected_labels:
        # Load from expected labels file
        if os.path.exists(expected_labels):
            df_expected = pd.read_csv(expected_labels)
            if 'Label' in df_expected.columns and len(df_expected) == len(df):
                y_true = df_expected['Label'].values
                print(f"   📌 Loaded ground truth from: {expected_labels}")
            else:
                print("   ❌ Error: Expected labels file invalid. Using sklearn predictions.")
                y_true = predictions_sklearn
        else:
            print(f"   ❌ Error: Expected labels file not found: {expected_labels}. Using sklearn predictions.")
            y_true = predictions_sklearn
    else:
        # Default: use sklearn predictions as ground truth
        y_true = predictions_sklearn
        print("   📌 Using sklearn predictions as ground truth")
    
    y_pred = df['Label'].values
    
    metrics = calculate_metrics(y_true, y_pred)
    
    # Add ground truth source info
    if ground_truth_mode == 'filename':
        metrics['ground_truth_source'] = 'filename (auto-detected)'
    elif ground_truth_mode == 'file':
        metrics['ground_truth_source'] = f'file ({expected_labels})'
    else:
        metrics['ground_truth_source'] = 'sklearn predictions'
    
    return df, metrics

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 evaluate_classification.py <csv_file> [options]")
        print("  csv_file: CSV output from kernel (with Label column)")
        print("")
        print("Options:")
        print("  --expected <file.csv>  : Use CSV file with expected labels as ground truth")
        print("  --filename             : Auto-detect ground truth from filename (attack/benign)")
        print("  --sklearn             : Use sklearn predictions as ground truth (default)")
        print("")
        print("Examples:")
        print("  python3 evaluate_classification.py output.csv")
        print("  python3 evaluate_classification.py output.csv --expected labels.csv")
        print("  python3 evaluate_classification.py output.csv --filename")
        sys.exit(1)
    
    csv_file = sys.argv[1]
    expected_file = None
    ground_truth_mode = 'sklearn'
    
    # Parse options
    i = 2
    while i < len(sys.argv):
        if sys.argv[i] == '--expected' and i + 1 < len(sys.argv):
            expected_file = sys.argv[i + 1]
            ground_truth_mode = 'file'
            i += 2
        elif sys.argv[i] == '--filename':
            ground_truth_mode = 'filename'
            i += 1
        elif sys.argv[i] == '--sklearn':
            ground_truth_mode = 'sklearn'
            i += 1
        elif sys.argv[i].endswith('.csv') and expected_file is None:
            # Backward compatibility: second arg as expected file
            expected_file = sys.argv[i]
            ground_truth_mode = 'file'
            i += 1
        else:
            i += 1
    
    print("=" * 70)
    print("DECISION TREE CLASSIFICATION EVALUATION")
    print("=" * 70)
    print(f"File: {csv_file}")
    print(f"Ground truth mode: {ground_truth_mode}")
    if expected_file:
        print(f"Expected labels file: {expected_file}")
    print()
    
    # Analyze CSV
    result = analyze_csv(csv_file, expected_file, ground_truth_mode)
    if result is None:
        sys.exit(1)
    
    df, metrics = result
    
    print("BASIC STATISTICS:")
    print("-" * 70)
    print(f"Total flows: {len(df)}")
    print(f"Kernel Label 0 (Normal): {len(df[df['Label'] == 0])}")
    print(f"Kernel Label 1 (Attack): {len(df[df['Label'] == 1])}")
    print(f"Sklearn Prediction 0 (Normal): {len(df[df['Prediction_Sklearn'] == 0])}")
    print(f"Sklearn Prediction 1 (Attack): {len(df[df['Prediction_Sklearn'] == 1])}")
    print()
    
    print("CLASSIFICATION METRICS:")
    print("-" * 70)
    print(f"Ground truth source: {metrics['ground_truth_source']}")
    print()
    print(f"True Positives (TP):  {metrics['tp']}")
    print(f"True Negatives (TN):  {metrics['tn']}")
    print(f"False Positives (FP): {metrics['fp']}")
    print(f"False Negatives (FN): {metrics['fn']}")
    print()
    print(f"Accuracy:  {metrics['accuracy']*100:.2f}%")
    print(f"Precision: {metrics['precision']*100:.2f}%")
    print(f"Recall:    {metrics['recall']*100:.2f}%")
    print(f"F1 Score:  {metrics['f1']*100:.2f}%")
    print()
    
    # Analyze false positives and false negatives
    false_positives = df[(df['Label'] == 1) & (df['Prediction_Sklearn'] == 0)]
    false_negatives = df[(df['Label'] == 0) & (df['Prediction_Sklearn'] == 1)]
    
    if len(false_positives) > 0:
        print("FALSE POSITIVES (Kernel says Attack, but Sklearn says Normal):")
        print("-" * 70)
        print(f"Count: {len(false_positives)}")
        if 'Probability_Attack' in false_positives.columns:
            print(f"Probability range: {false_positives['Probability_Attack'].min():.3f} to {false_positives['Probability_Attack'].max():.3f}")
            print(f"Probability mean: {false_positives['Probability_Attack'].mean():.3f}")
        print()
    
    if len(false_negatives) > 0:
        print("FALSE NEGATIVES (Kernel says Normal, but Sklearn says Attack):")
        print("-" * 70)
        print(f"Count: {len(false_negatives)}")
        if 'Probability_Attack' in false_negatives.columns:
            print(f"Probability range: {false_negatives['Probability_Attack'].min():.3f} to {false_negatives['Probability_Attack'].max():.3f}")
            print(f"Probability mean: {false_negatives['Probability_Attack'].mean():.3f}")
        print()
    
    # Probability distribution
    print("PROBABILITY DISTRIBUTION:")
    print("-" * 70)
    print(f"All flows:")
    print(f"  Attack probability - Min: {df['Probability_Attack'].min():.3f}, Max: {df['Probability_Attack'].max():.3f}, Mean: {df['Probability_Attack'].mean():.3f}")
    print(f"Kernel Label 0 (Normal):")
    print(f"  Attack probability - Min: {df[df['Label']==0]['Probability_Attack'].min():.3f}, Max: {df[df['Label']==0]['Probability_Attack'].max():.3f}, Mean: {df[df['Label']==0]['Probability_Attack'].mean():.3f}")
    print(f"Kernel Label 1 (Attack):")
    print(f"  Attack probability - Min: {df[df['Label']==1]['Probability_Attack'].min():.3f}, Max: {df[df['Label']==1]['Probability_Attack'].max():.3f}, Mean: {df[df['Label']==1]['Probability_Attack'].mean():.3f}")
    print()
    
    # Confusion matrix
    print("CONFUSION MATRIX:")
    print("-" * 70)
    print("                    Predicted")
    print("                 Normal  Attack")
    print(f"Actual Normal    {metrics['tn']:4d}    {metrics['fp']:4d}")
    print(f"        Attack    {metrics['fn']:4d}    {metrics['tp']:4d}")
    print()
    
    # If expected file provided, compare
    if expected_file and os.path.exists(expected_file):
        print("COMPARING WITH EXPECTED LABELS:")
        print("-" * 70)
        df_expected = pd.read_csv(expected_file)
        # Assume expected file has same structure or has Label column
        if 'Label' in df_expected.columns and len(df_expected) == len(df):
            expected_labels = df_expected['Label'].values
            expected_metrics = calculate_metrics(expected_labels, df['Label'].values)
            print(f"Accuracy vs expected: {expected_metrics['accuracy']*100:.2f}%")
            print(f"Precision vs expected: {expected_metrics['precision']*100:.2f}%")
            print(f"Recall vs expected: {expected_metrics['recall']*100:.2f}%")
            print(f"F1 vs expected: {expected_metrics['f1']*100:.2f}%")
            print()
    
    print("=" * 70)

if __name__ == "__main__":
    main()


