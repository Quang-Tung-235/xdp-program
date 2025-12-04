#!/bin/bash
# Test script for DDoS detection XDP program - Real Interface Version (Decision Tree)
# Usage:
#   ./test_ddos_detection.sh [interface]                    # Live traffic
#   ./test_ddos_detection.sh [interface] --pcap <file1> [file2] ...  # Test with PCAP files
#   ./test_ddos_detection.sh [interface] --csv <file1> [file2] ...  # Evaluate CSV files
# Default interface: wlo1 (WiFi)

set -e

# Parse arguments
IFNAME=""
MODE="live"
FILES=()
EXPECTING_FILES=0

# Parse interface (first non-option argument)
for arg in "$@"; do
    if [[ "$arg" == --pcap ]]; then
        MODE="pcap"
        EXPECTING_FILES=1
    elif [[ "$arg" == --csv ]]; then
        MODE="csv"
        EXPECTING_FILES=1
    elif [[ "$arg" != --* ]] && [ -z "$IFNAME" ] && [ "$EXPECTING_FILES" -eq 0 ]; then
        # First non-option argument is interface (if not expecting files)
        IFNAME="$arg"
    elif [[ "$arg" != --* ]]; then
        # This is a file (either after --pcap/--csv or after interface)
        # Expand tilde in file paths
        FILE_PATH="${arg/#\~/$HOME}"
        if [ -f "$FILE_PATH" ]; then
            FILES+=("$FILE_PATH")
        else
            echo "⚠️  Warning: File not found: $FILE_PATH"
        fi
    fi
done

# Default interface
IFNAME=${IFNAME:-wlo1}

# Function to cleanup XDP on exit
cleanup_xdp() {
    echo ""
    echo "🧹 Cleaning up XDP program from $IFNAME..."
    sudo ip link set dev $IFNAME xdpgeneric off 2>/dev/null || true
    sudo rm -rf /sys/fs/bpf/$IFNAME 2>/dev/null || true
    echo "✅ XDP program removed"
}

# Trap to ensure cleanup on exit (success or failure)
trap cleanup_xdp EXIT

echo "=========================================="
echo "DDoS Detection XDP Program Test Script (Decision Tree)"
echo "=========================================="
echo "Interface: $IFNAME (Real Interface)"
echo "Mode: $MODE"
if [ ${#FILES[@]} -gt 0 ]; then
    echo "Files: ${#FILES[@]} file(s)"
    for file in "${FILES[@]}"; do
        echo "  - $file"
    done
fi
echo ""

# CSV evaluation mode
if [ "$MODE" == "csv" ]; then
    if [ ${#FILES[@]} -eq 0 ]; then
        echo "❌ Error: No CSV files provided for --csv mode"
        echo "Usage: ./test_ddos_detection.sh [interface] --csv <file1.csv> [file2.csv] ..."
        exit 1
    fi
    
    # Find evaluate_classification.py
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    EVAL_SCRIPT=""
    if [ -f "$SCRIPT_DIR/../xdp_prog/evaluate_classification.py" ]; then
        EVAL_SCRIPT="$SCRIPT_DIR/../xdp_prog/evaluate_classification.py"
    elif [ -f "$SCRIPT_DIR/evaluate_classification.py" ]; then
        EVAL_SCRIPT="$SCRIPT_DIR/evaluate_classification.py"
    elif [ -f "./evaluate_classification.py" ]; then
        EVAL_SCRIPT="./evaluate_classification.py"
    fi
    
    if [ -z "$EVAL_SCRIPT" ]; then
        echo "❌ Error: evaluate_classification.py not found"
        exit 1
    fi
    
    echo "Evaluating CSV files..."
    echo ""
    echo "Note: CSV evaluation compares kernel predictions with sklearn predictions"
    echo "      (sklearn is used as ground truth reference)"
    echo ""
    echo "Options for ground truth:"
    echo "  - Default: sklearn predictions (automatic)"
    echo "  - --filename: Auto-detect from filename (attack/benign)"
    echo "  - --expected <file.csv>: Use CSV file with ground truth labels"
    echo ""
    
    for csv_file in "${FILES[@]}"; do
        echo ""
        echo "=========================================="
        echo "Evaluating: $csv_file"
        echo "=========================================="
        
        # Try to auto-detect ground truth mode from filename
        GROUND_TRUTH_MODE="--sklearn"
        CSV_BASENAME=$(basename "$csv_file" | tr '[:upper:]' '[:lower:]')
        if [[ "$CSV_BASENAME" == *"attack"* ]]; then
            echo "   📌 Detected 'attack' in filename, using --filename mode"
            GROUND_TRUTH_MODE="--filename"
        elif [[ "$CSV_BASENAME" == *"benign"* ]] || [[ "$CSV_BASENAME" == *"normal"* ]]; then
            echo "   📌 Detected 'benign/normal' in filename, using --filename mode"
            GROUND_TRUTH_MODE="--filename"
        else
            echo "   📌 Using sklearn predictions as ground truth (default)"
        fi
        
        python3 "$EVAL_SCRIPT" "$csv_file" $GROUND_TRUTH_MODE 2>&1 || echo "   ⚠️  Evaluation failed"
    done
    
    echo ""
    echo "=========================================="
    echo "CSV Evaluation Completed"
    echo "=========================================="
    echo ""
    echo "To use different ground truth mode:"
    echo "  python3 evaluate_classification.py <csv_file> --sklearn    # Use sklearn (default)"
    echo "  python3 evaluate_classification.py <csv_file> --filename  # Auto-detect from filename"
    echo "  python3 evaluate_classification.py <csv_file> --expected <ground_truth.csv>"
    
    exit 0
fi

# Step 1: Clean up any existing XDP program
echo "[1/6] Cleaning up existing XDP program..."
sudo ip link set dev $IFNAME xdpgeneric off 2>/dev/null || true
sudo rm -rf /sys/fs/bpf/$IFNAME 2>/dev/null || true
echo "✅ Cleanup done"
echo ""

# Step 2: Build the program
echo "[2/6] Building XDP program..."

# Find the directory containing Makefile (xdp_prog)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/Makefile" ]; then
    BUILD_DIR="$SCRIPT_DIR"
elif [ -f "$SCRIPT_DIR/../xdp_prog/Makefile" ]; then
    BUILD_DIR="$SCRIPT_DIR/../xdp_prog"
elif [ -f "./Makefile" ]; then
    BUILD_DIR="."
else
    echo "❌ Error: Cannot find Makefile. Please run from xdp_prog directory or ensure script is in correct location."
    exit 1
fi

cd "$BUILD_DIR"
echo "   Building in: $BUILD_DIR"
make clean
make
if [ ! -f ./xdp_loader ] || [ ! -f ./xdp_prog_kern.o ]; then
    echo "❌ Build failed!"
    exit 1
fi
echo "✅ Build successful"
echo ""

# Step 3: Load XDP program
echo "[3/6] Loading XDP program to interface $IFNAME..."

# Check if interface exists
if ! ip link show "$IFNAME" &>/dev/null; then
    echo "❌ Error: Interface $IFNAME does not exist"
    echo "Available interfaces:"
    ip link show | grep -E "^[0-9]+:" | awk '{print "  - " $2}' | sed 's/://'
    exit 1
fi

# Use --skb-mode for WiFi interfaces (most real interfaces need this)
sudo "$BUILD_DIR/xdp_loader" -d $IFNAME --skb-mode
if [ $? -ne 0 ]; then
    echo "❌ Failed to load XDP program"
    exit 1
fi
echo "✅ XDP program loaded"
echo ""

# Step 4: Load model into BPF map
echo "[4/6] Loading Decision Tree model into BPF map..."
if [ ! -f "$BUILD_DIR/decision_tree_model_6_features.pkl" ]; then
    echo "❌ Model file not found! Please run train_model.py first"
    exit 1
fi

MAP_PATH="/sys/fs/bpf/$IFNAME/dt_map"
sudo python3 "$BUILD_DIR/read_model_to_map.py" \
    "$BUILD_DIR/decision_tree_model_6_features.pkl" \
    $MAP_PATH

if [ $? -ne 0 ]; then
    echo "❌ Failed to load model"
    exit 1
fi
echo "✅ Model loaded successfully"
echo ""

# Step 5: Monitor/Capture traffic
echo "[5/6] Monitoring traffic on interface $IFNAME..."
FLOW_MAP="/sys/fs/bpf/$IFNAME/xdp_flow_tracking"

if [ "$MODE" == "pcap" ] && [ ${#FILES[@]} -gt 0 ]; then
    # PCAP replay mode
    if ! command -v tcpreplay &> /dev/null; then
        echo "❌ tcpreplay not found. Please install it:"
        echo "   sudo apt-get install tcpreplay"
        exit 1
    fi
    
    # Get interface MAC for rewriting (packets sent directly to interface MAC, bypassing network stack)
    IFACE_MAC=$(ip link show "$IFNAME" 2>/dev/null | grep -oP 'link/ether \K[^ ]+' | tr '[:upper:]' '[:lower:]')
    
    TOTAL_PACKETS=0
    for PCAP_FILE in "${FILES[@]}"; do
        echo ""
        echo "   Processing: $PCAP_FILE"
        
        # Auto-rewrite MAC if needed (to send directly to interface, bypassing network stack)
        REWRITE_SCRIPT=""
        if [ -f "$BUILD_DIR/rewrite_pcap_mac.sh" ]; then
            REWRITE_SCRIPT="$BUILD_DIR/rewrite_pcap_mac.sh"
        elif [ -f "./rewrite_pcap_mac.sh" ]; then
            REWRITE_SCRIPT="./rewrite_pcap_mac.sh"
        fi
        
        if [ -n "$IFACE_MAC" ] && [ -n "$REWRITE_SCRIPT" ]; then
            # Check if MAC rewriting is needed
            ORIG_DST_MAC=$(tcpdump -r "$PCAP_FILE" -n -c 1 -e 2>&1 | grep -oP '> \K[0-9a-f:]{17}' | head -1 | tr '[:upper:]' '[:lower:]' || echo "")
            
            if [ -z "$ORIG_DST_MAC" ] || [ "$ORIG_DST_MAC" != "$IFACE_MAC" ]; then
                echo "   📡 Rewriting PCAP destination MAC to interface MAC ($IFACE_MAC)"
                echo "   (This ensures packets are sent directly to interface, bypassing network stack)"
                REWRITTEN_PCAP="${PCAP_FILE%.*}_rewritten_mac_${IFACE_MAC//:/_}.pcap"
                # Run rewrite script and capture exit code
                if bash "$REWRITE_SCRIPT" "$PCAP_FILE" "$IFNAME" "$REWRITTEN_PCAP" >/dev/null 2>&1; then
                    if [ -f "$REWRITTEN_PCAP" ]; then
                        PCAP_FILE="$REWRITTEN_PCAP"
                        echo "   ✅ Using rewritten PCAP: $PCAP_FILE"
                    else
                        echo "   ⚠️  MAC rewrite completed but output file not found, using original PCAP"
                    fi
                else
                    echo "   ⚠️  MAC rewrite failed, using original PCAP"
                fi
            else
                echo "   ✅ PCAP destination MAC already matches interface MAC"
            fi
        fi
        
        # Get PCAP info
        PCAP_PACKETS=$(tcpdump -r "$PCAP_FILE" -n 2>&1 | grep -c "^[0-9]" || echo "0")
        TOTAL_PACKETS=$((TOTAL_PACKETS + PCAP_PACKETS))
        
        # Replay PCAP (similar to scripts_tcpreplay.sh)
        # Note: For real interfaces, tcpreplay sends packets OUT, XDP only sees INCOMING
        # So we use lower PPS and wait longer
        PPS=${PPS:-1000}  # Lower PPS for real interfaces
        echo "   Replaying $PCAP_PACKETS packets at ${PPS} PPS..."
        
        START_TIME=$(date +%s)
        sudo tcpreplay -i "$IFNAME" --pps="$PPS" --loop=1 "$PCAP_FILE" 2>&1 | \
            grep -v "Message too long" | grep -v "Warning" || true
        REPLAY_DURATION=$(( $(date +%s) - START_TIME ))
        
        echo "   ✅ Replay completed in ${REPLAY_DURATION}s"
        
        # Wait for flows to be processed
        WAIT_TIME=5
        if [ "$PCAP_PACKETS" -gt 200 ]; then
            WAIT_TIME=10
        fi
        if [ "$PCAP_PACKETS" -gt 500 ]; then
            WAIT_TIME=15
        fi
        echo "   Waiting ${WAIT_TIME}s for flows to be processed..."
        sleep $WAIT_TIME
    done
    
    echo ""
    echo "   Total packets replayed: $TOTAL_PACKETS"
    
else
    # Live traffic mode
    echo "   No PCAP files provided. Monitoring real traffic for 10 seconds..."
    echo "   (Make sure there is network activity on $IFNAME)"
    echo "   You can generate traffic manually (browse web, ping, etc.)"
    sleep 10
fi

echo "   Waiting 3 seconds for flows to be processed by XDP..."
sleep 3
echo "✅ Traffic monitoring completed"
echo ""

# Step 6: Dump map to CSV
echo "[6/6] Dumping flow data to CSV..."

# Check if map exists (with sudo since it's in /sys/fs/bpf)
if sudo test ! -e "$FLOW_MAP"; then
    echo "❌ Flow tracking map does not exist at $FLOW_MAP"
    echo "   Checking what maps exist in /sys/fs/bpf/$IFNAME/:"
    sudo ls -la /sys/fs/bpf/$IFNAME/ 2>&1 | head -10 || echo "   Directory does not exist"
    echo "   Check if XDP program was loaded correctly"
    exit 1
fi

echo "   ✅ Map exists at $FLOW_MAP"

# Count flows using bpftool if available
FLOW_COUNT=0
if command -v bpftool &> /dev/null; then
    FLOW_COUNT=$(sudo bpftool map dump pinned "$FLOW_MAP" 2>/dev/null | grep -c "key" 2>/dev/null || echo "0")
    FLOW_COUNT=$(echo "$FLOW_COUNT" | tr -d '\n' | head -1)
    if ! [[ "$FLOW_COUNT" =~ ^[0-9]+$ ]]; then
        FLOW_COUNT=0
    fi
    echo "   Found $FLOW_COUNT flows in map"
    if [ "$FLOW_COUNT" -eq 0 ]; then
        echo "   ⚠️  WARNING: No flows detected in map!"
        echo "   Possible issues:"
        echo "      - XDP only processes INCOMING packets (not outgoing)"
        echo "      - Real interfaces may not capture all replayed packets"
        echo "      - Consider using comprehensive_test.sh with veth for better results"
        echo "   Checking XDP attachment..."
        ip link show $IFNAME | grep -i xdp || echo "      ❌ XDP not attached!"
    fi
fi

OUTPUT_CSV="test_output_$(date +%Y%m%d_%H%M%S).csv"
sudo "$BUILD_DIR/dump_map_to_csv" $IFNAME "$OUTPUT_CSV"
if [ $? -ne 0 ]; then
    echo "❌ Failed to dump map"
    exit 1
fi

if [ -f "$OUTPUT_CSV" ]; then
    LINE_COUNT=$(wc -l < "$OUTPUT_CSV")
    CSV_FLOW_COUNT=$((LINE_COUNT - 1))
    echo "✅ Dumped $CSV_FLOW_COUNT flows to $OUTPUT_CSV"
    echo ""
    
    if [ "$CSV_FLOW_COUNT" -gt 0 ]; then
        echo "First 10 lines of output:"
        head -10 "$OUTPUT_CSV"
        echo ""
        echo "Label distribution:"
        tail -n +2 "$OUTPUT_CSV" | cut -d',' -f12 | sort | uniq -c || echo "No flows detected"
        echo ""
        
        # Evaluate classification if evaluate script exists
        EVAL_SCRIPT=""
        if [ -f "$BUILD_DIR/evaluate_classification.py" ]; then
            EVAL_SCRIPT="$BUILD_DIR/evaluate_classification.py"
        elif [ -f "./evaluate_classification.py" ]; then
            EVAL_SCRIPT="./evaluate_classification.py"
        fi
        
        if [ -n "$EVAL_SCRIPT" ]; then
            echo ""
            echo "[7/7] Evaluating classification results..."
            echo "=========================================="
            python3 "$EVAL_SCRIPT" "$OUTPUT_CSV" 2>&1 || echo "   ⚠️  Evaluation script failed"
        fi
    else
        echo "⚠️  WARNING: CSV file is empty (only header)"
        echo "   This means no flows were tracked."
        echo "   💡 Tip: For PCAP testing, use comprehensive_test.sh with veth interface"
    fi
else
    echo "❌ Output file not created"
    exit 1
fi

echo ""
echo "=========================================="
echo "Test completed successfully!"
echo "Output file: $OUTPUT_CSV"
echo "=========================================="
echo ""
echo "Note: XDP program will be automatically removed on exit"

