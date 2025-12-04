#!/bin/bash
# Comprehensive test script for DDoS detection - Veth Interface Version (Decision Tree)
# Automatically detects veth peer and replays PCAP on peer interface
# Usage:
#   ./comprehensive_test.sh [veth_interface] [pcap_file1] [pcap_file2] ...
#   ./comprehensive_test.sh [veth_interface] --pcap <file1> [file2] ...
# Default: Uses veth_test_server if available

set -e

# Parse arguments
IFNAME=""
FILES=()
PPS=10000  # Default PPS (can be adjusted)
AUTO_VETH_CREATED=0  # 1 if this script auto-creates veth and should delete it after test

# Parse interface and files
for arg in "$@"; do
    if [[ "$arg" == --pcap ]]; then
        continue
    elif [[ "$arg" == --pps ]]; then
        continue
    elif [[ "$arg" =~ ^[0-9]+$ ]] && [ -z "$PPS_SET" ]; then
        PPS="$arg"
        PPS_SET=1
    elif [[ "$arg" != --* ]] && [ -z "$IFNAME" ]; then
        IFNAME="$arg"
    elif [[ "$arg" != --* ]] && [ -n "$IFNAME" ]; then
        FILE_PATH="${arg/#\~/$HOME}"
        if [ -f "$FILE_PATH" ]; then
            FILES+=("$FILE_PATH")
        else
            echo "⚠️  Warning: File not found: $FILE_PATH"
        fi
    fi
done

# Auto-detect veth interface if not provided
if [ -z "$IFNAME" ]; then
    if ip link show veth_test_server &>/dev/null; then
        IFNAME="veth_test_server"
    elif ip link show veth_server &>/dev/null; then
        IFNAME="veth_server"
    else
        echo "ℹ️  No existing veth interface found, creating temporary veth_test_client <-> veth_test_server..."
        VETH_CLIENT="veth_test_client"
        VETH_SERVER="veth_test_server"
        SERVER_IP="192.168.50.4"
        CLIENT_IP="192.168.50.5"

        # Cleanup existing if any
        sudo ip link delete "$VETH_CLIENT" 2>/dev/null || true
        sudo ip link delete "$VETH_SERVER" 2>/dev/null || true

        # Create veth pair (compatible with your ip syntax)
        sudo ip link add "$VETH_CLIENT" type veth peer "$VETH_SERVER"

        # Assign IP addresses
        sudo ip addr add "${SERVER_IP}/24" dev "$VETH_SERVER"
        sudo ip addr add "${CLIENT_IP}/24" dev "$VETH_CLIENT"

        # Bring interfaces up
        sudo ip link set "$VETH_CLIENT" up
        sudo ip link set "$VETH_SERVER" up

        # Best-effort: disable offloading
        sudo ethtool -K "$VETH_CLIENT" tx off rx off 2>/dev/null || true
        sudo ethtool -K "$VETH_SERVER" tx off rx off 2>/dev/null || true

        IFNAME="$VETH_SERVER"
        AUTO_VETH_CREATED=1

        echo "✅ Created temporary veth pair:"
        echo "   $VETH_CLIENT: $CLIENT_IP"
        echo "   $VETH_SERVER: $SERVER_IP (XDP attach here)"
        echo ""
    fi
fi

# Function to cleanup XDP on exit
cleanup_xdp() {
    echo ""
    echo "🧹 Cleaning up XDP program from $IFNAME..."
    sudo ip link set dev $IFNAME xdpgeneric off 2>/dev/null || true
    sudo rm -rf /sys/fs/bpf/$IFNAME 2>/dev/null || true
    echo "✅ XDP program removed"

    # If we created a temporary veth pair, remove it now
    if [ "$AUTO_VETH_CREATED" -eq 1 ]; then
        echo "🧹 Removing temporary veth pair veth_test_client <-> veth_test_server..."
        sudo ip link delete veth_test_client 2>/dev/null || true
        sudo ip link delete veth_test_server 2>/dev/null || true
        echo "✅ Veth pair removed"
    fi
}

# Trap to ensure cleanup on exit
trap cleanup_xdp EXIT

echo "=========================================="
echo "DDoS Detection XDP Program - Comprehensive Test (Decision Tree)"
echo "=========================================="
echo "Interface: $IFNAME (Veth Interface)"
if [ ${#FILES[@]} -gt 0 ]; then
    echo "PCAP files: ${#FILES[@]} file(s)"
    for file in "${FILES[@]}"; do
        echo "  - $file"
    done
fi
echo ""

# Find veth peer interface
REPLAY_IFACE="$IFNAME"
PEER_IFACE=""

# Method 1: Check /sys/class/net for peer
if [ -L "/sys/class/net/$IFNAME/peer" ]; then
    PEER_IFACE=$(basename $(readlink "/sys/class/net/$IFNAME/peer") 2>/dev/null || echo "")
fi

# Method 2: Check all veth interfaces
if [ -z "$PEER_IFACE" ] || [ "$PEER_IFACE" == "$IFNAME" ]; then
    for veth in $(ip -o link show type veth 2>/dev/null | awk -F': ' '{print $2}'); do
        if [ "$veth" != "$IFNAME" ]; then
            if [ -L "/sys/class/net/$veth/peer" ]; then
                VETH_PEER=$(basename $(readlink "/sys/class/net/$veth/peer") 2>/dev/null || echo "")
                if [ "$VETH_PEER" == "$IFNAME" ]; then
                    PEER_IFACE="$veth"
                    break
                fi
            fi
        fi
    done
fi

# Method 3: Common naming patterns
if [ -z "$PEER_IFACE" ] || [ "$PEER_IFACE" == "$IFNAME" ]; then
    case "$IFNAME" in
        veth_test_server|veth_server)
            if ip link show veth_test_client &>/dev/null; then
                PEER_IFACE="veth_test_client"
            elif ip link show veth_client &>/dev/null; then
                PEER_IFACE="veth_client"
            fi
            ;;
        veth_test_client|veth_client)
            if ip link show veth_test_server &>/dev/null; then
                PEER_IFACE="veth_test_server"
            elif ip link show veth_server &>/dev/null; then
                PEER_IFACE="veth_server"
            fi
            ;;
    esac
fi

if [ -n "$PEER_IFACE" ] && [ "$PEER_IFACE" != "$IFNAME" ] && ip link show "$PEER_IFACE" &>/dev/null; then
    echo "📌 Detected veth peer: $PEER_IFACE"
    echo "📌 XDP attached to: $IFNAME"
    echo "📌 PCAP will be replayed on: $PEER_IFACE (packets enter $IFNAME)"
    REPLAY_IFACE="$PEER_IFACE"
    echo ""
else
    echo "⚠️  WARNING: Could not find veth peer for $IFNAME"
    echo "   Replaying on $IFNAME (may not capture all flows)"
    echo "   💡 Tip: Use setup_veth_test.sh to create veth pair properly"
    echo ""
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

sudo "$BUILD_DIR/xdp_loader" -d $IFNAME
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

# Step 5: Replay PCAP files (similar to scripts_tcpreplay.sh)
echo "[5/6] Replaying PCAP files on $REPLAY_IFACE..."
FLOW_MAP="/sys/fs/bpf/$IFNAME/xdp_flow_tracking"

if [ ${#FILES[@]} -eq 0 ]; then
    echo "   No PCAP files provided. Monitoring traffic for 10 seconds..."
    echo "   (Generate traffic on $PEER_IFACE if available)"
    sleep 10
else
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
        
        # Estimate flows
        ESTIMATED_FLOWS=$(tcpdump -r "$PCAP_FILE" -n -c 500 2>&1 | awk '/^[0-9]/ {if ($3 ~ /^[0-9]/ && $5 ~ /^[0-9]/) {split($3, s, /[.:]/); split($5, d, /[.:]/); if (s[1] ~ /^[0-9]/ && d[1] ~ /^[0-9]/) {src=s[1]"."s[2]"."s[3]"."s[4]":"s[5]; dst=d[1]"."d[2]"."d[3]"."d[4]":"d[5]; proto="6"; if ($0 ~ /UDP/) proto="17"; if ($0 ~ /ICMP/) proto="1"; if ($0 ~ /TCP|UDP|ICMP/) print src"->"dst":"proto}}}' | sort -u | wc -l)
        
        # Replay PCAP (similar to scripts_tcpreplay.sh)
        echo "   Replaying $PCAP_PACKETS packets at ${PPS} PPS..."
        if [ "$ESTIMATED_FLOWS" -gt 0 ]; then
            echo "   Estimated flows: ~$ESTIMATED_FLOWS"
        fi
        
        START_TS=$(date '+%Y-%m-%d %H:%M:%S')
        START_TIME=$(date +%s)
        
        # Replay with monitoring (similar to scripts_tcpreplay.sh)
        sudo tcpreplay -i "$REPLAY_IFACE" --pps="$PPS" --loop=1 "$PCAP_FILE" 2>&1 | \
            grep -v "Message too long" | grep -v "Warning" &
        REPLAY_PID=$!
        
        # Monitor flows during replay
        FLOW_COUNT_PREV=0
        while kill -0 $REPLAY_PID 2>/dev/null; do
            sleep 0.5
            if command -v bpftool &> /dev/null; then
                CURRENT_COUNT=$(sudo bpftool map dump pinned "$FLOW_MAP" 2>/dev/null | grep -c "key" 2>/dev/null || echo "0")
                CURRENT_COUNT=$(echo "$CURRENT_COUNT" | tr -d '\n' | head -1)
                if ! [[ "$CURRENT_COUNT" =~ ^[0-9]+$ ]]; then
                    CURRENT_COUNT=0
                fi
                if [ "$CURRENT_COUNT" -ne "$FLOW_COUNT_PREV" ]; then
                    echo "   Flows: $CURRENT_COUNT (increasing...)"
                    FLOW_COUNT_PREV=$CURRENT_COUNT
                fi
            fi
        done
        
        wait $REPLAY_PID 2>/dev/null || true
        REPLAY_EXIT=$?
        END_TIME=$(date +%s)
        REPLAY_DURATION=$((END_TIME - START_TIME))
        
        echo "   ✅ Replay completed in ${REPLAY_DURATION}s (exit code: $REPLAY_EXIT)"
        
        # Wait for flows to be processed
        WAIT_TIME=10
        if [ "$PCAP_PACKETS" -gt 200 ]; then
            WAIT_TIME=15
        fi
        if [ "$PCAP_PACKETS" -gt 500 ]; then
            WAIT_TIME=20
        fi
        echo "   Waiting ${WAIT_TIME}s for flows to be processed..."
        
        # Continue monitoring
        LAST_REPORTED=$FLOW_COUNT_PREV
        for i in $(seq 1 $WAIT_TIME); do
            sleep 1
            if command -v bpftool &> /dev/null && [ $((i % 3)) -eq 0 ]; then
                CURRENT_COUNT=$(sudo bpftool map dump pinned "$FLOW_MAP" 2>/dev/null | grep -c "key" 2>/dev/null || echo "0")
                CURRENT_COUNT=$(echo "$CURRENT_COUNT" | tr -d '\n' | head -1)
                if ! [[ "$CURRENT_COUNT" =~ ^[0-9]+$ ]]; then
                    CURRENT_COUNT=0
                fi
                if [ "$CURRENT_COUNT" -ne "$LAST_REPORTED" ]; then
                    echo "   After ${i}s: $CURRENT_COUNT flows (increased from $LAST_REPORTED)"
                    LAST_REPORTED=$CURRENT_COUNT
                fi
            fi
        done
    done
    
    echo ""
    echo "   Total packets replayed: $TOTAL_PACKETS"
fi

echo "✅ Traffic replay completed"
echo ""

# Step 6: Dump map to CSV
echo "[6/6] Dumping flow data to CSV..."

if [ ! -e "$FLOW_MAP" ]; then
    echo "❌ Flow tracking map does not exist at $FLOW_MAP"
    exit 1
fi

# Count flows
FLOW_COUNT=0
if command -v bpftool &> /dev/null; then
    FLOW_COUNT=$(sudo bpftool map dump pinned "$FLOW_MAP" 2>/dev/null | grep -c "key" 2>/dev/null || echo "0")
    FLOW_COUNT=$(echo "$FLOW_COUNT" | tr -d '\n' | head -1)
    if ! [[ "$FLOW_COUNT" =~ ^[0-9]+$ ]]; then
        FLOW_COUNT=0
    fi
    echo "   Found $FLOW_COUNT flows in map"
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
        
        # Evaluate classification
        EVAL_SCRIPT=""
        if [ -f "$BUILD_DIR/evaluate_classification.py" ]; then
            EVAL_SCRIPT="$BUILD_DIR/evaluate_classification.py"
        elif [ -f "./evaluate_classification.py" ]; then
            EVAL_SCRIPT="./evaluate_classification.py"
        fi
        
        if [ -n "$EVAL_SCRIPT" ]; then
            echo "[7/7] Evaluating classification results..."
            python3 "$EVAL_SCRIPT" "$OUTPUT_CSV" 2>&1 || echo "   ⚠️  Evaluation script failed"
        fi
    else
        echo "⚠️  WARNING: CSV file is empty (only header)"
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

