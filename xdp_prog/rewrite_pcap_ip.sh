#!/bin/bash
# Rewrite PCAP file to change destination IP to match interface IP
# Usage: ./rewrite_pcap_ip.sh <pcap_file> <interface> [output_file]

PCAP_FILE=${1:-""}
IFNAME=${2:-""}
OUTPUT_FILE=${3:-""}

if [ -z "$PCAP_FILE" ] || [ -z "$IFNAME" ]; then
    echo "Usage: ./rewrite_pcap_ip.sh <pcap_file> <interface> [output_file]"
    echo "Example: ./rewrite_pcap_ip.sh ~/Downloads/200attack.pcap wlo1"
    exit 1
fi

if [ ! -f "$PCAP_FILE" ]; then
    echo "❌ PCAP file not found: $PCAP_FILE"
    exit 1
fi

# Get interface IP
IFACE_IP=$(ip addr show "$IFNAME" 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d'/' -f1)
if [ -z "$IFACE_IP" ]; then
    echo "❌ Failed to get IP address for interface $IFNAME"
    exit 1
fi

echo "Interface: $IFNAME"
echo "Interface IP: $IFACE_IP"
echo "PCAP file: $PCAP_FILE"
echo ""

# Get original destination IP from PCAP
ORIG_DST_IP=$(tcpdump -r "$PCAP_FILE" -n -c 1 2>&1 | awk '/^[0-9]/ {if ($5 ~ /^[0-9]/) {split($5, d, /[.:]/); if (d[1] ~ /^[0-9]/) print d[1]"."d[2]"."d[3]"."d[4]}}' | head -1)

if [ -z "$ORIG_DST_IP" ]; then
    echo "❌ Failed to extract destination IP from PCAP"
    exit 1
fi

echo "Original destination IP in PCAP: $ORIG_DST_IP"

if [ "$ORIG_DST_IP" == "$IFACE_IP" ]; then
    echo "✅ PCAP destination IP already matches interface IP. No rewrite needed."
    exit 0
fi

# Generate output filename if not provided
if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="${PCAP_FILE%.*}_rewritten_${IFACE_IP//./_}.pcap"
fi

echo "Rewriting destination IP: $ORIG_DST_IP -> $IFACE_IP"
echo "Output file: $OUTPUT_FILE"
echo ""

# Check if tcprewrite is available
if command -v tcprewrite &> /dev/null; then
    echo "Using tcprewrite..."
    # Rewrite destination IP (no sudo needed for file operations)
    tcprewrite --dstipmap=$ORIG_DST_IP:$IFACE_IP --infile="$PCAP_FILE" --outfile="$OUTPUT_FILE" 2>&1 | grep -v "Warning" || true
    
    if [ $? -eq 0 ] && [ -f "$OUTPUT_FILE" ]; then
        echo "✅ PCAP rewritten successfully"
        echo ""
        echo "Verifying rewrite..."
        NEW_DST_IP=$(tcpdump -r "$OUTPUT_FILE" -n -c 1 2>&1 | awk '/^[0-9]/ {if ($5 ~ /^[0-9]/) {split($5, d, /[.:]/); if (d[1] ~ /^[0-9]/) print d[1]"."d[2]"."d[3]"."d[4]}}' | head -1)
        if [ "$NEW_DST_IP" == "$IFACE_IP" ]; then
            echo "✅ Verification successful: destination IP is now $NEW_DST_IP"
        else
            echo "⚠️  Warning: Verification shows destination IP is $NEW_DST_IP (expected $IFACE_IP)"
        fi
    else
        echo "❌ Failed to rewrite PCAP"
        exit 1
    fi
elif command -v editcap &> /dev/null; then
    echo "⚠️  editcap found but IP rewriting requires tcprewrite"
    echo "   Please install tcpreplay package: sudo apt-get install tcpreplay"
    exit 1
else
    echo "❌ Neither tcprewrite nor editcap found"
    echo "   Please install tcpreplay package: sudo apt-get install tcpreplay"
    exit 1
fi

echo ""
echo "To use the rewritten PCAP:"
echo "  sudo ./test_ddos_detection.sh $IFNAME --pcap $OUTPUT_FILE"

