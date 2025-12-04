#!/bin/bash
# Rewrite PCAP file to change destination MAC to match interface MAC
# This ensures packets are sent directly to the interface without going through network stack
# Usage: ./rewrite_pcap_mac.sh <pcap_file> <interface> [output_file]

PCAP_FILE=${1:-""}
IFNAME=${2:-""}
OUTPUT_FILE=${3:-""}

if [ -z "$PCAP_FILE" ] || [ -z "$IFNAME" ]; then
    echo "Usage: ./rewrite_pcap_mac.sh <pcap_file> <interface> [output_file]"
    echo "Example: ./rewrite_pcap_mac.sh ~/Downloads/200attack.pcap wlo1"
    exit 1
fi

if [ ! -f "$PCAP_FILE" ]; then
    echo "❌ PCAP file not found: $PCAP_FILE"
    exit 1
fi

# Get interface MAC address
IFACE_MAC=$(ip link show "$IFNAME" 2>/dev/null | grep -oP 'link/ether \K[^ ]+' | tr '[:upper:]' '[:lower:]')
if [ -z "$IFACE_MAC" ]; then
    echo "❌ Failed to get MAC address for interface $IFNAME"
    exit 1
fi

echo "Interface: $IFNAME"
echo "Interface MAC: $IFACE_MAC"
echo "PCAP file: $PCAP_FILE"
echo ""

# Get original destination MAC from PCAP (first packet)
ORIG_DST_MAC=$(tcpdump -r "$PCAP_FILE" -n -c 1 -e 2>&1 | grep -oP '> \K[0-9a-f:]{17}' | head -1 | tr '[:upper:]' '[:lower:]')

if [ -z "$ORIG_DST_MAC" ]; then
    # Try alternative method
    ORIG_DST_MAC=$(tcpdump -r "$PCAP_FILE" -n -c 1 -e 2>&1 | awk '/ether/ {for(i=1;i<=NF;i++) if($i ~ /^[0-9a-f:]{17}$/ && $i ~ />/) {gsub(/>/, "", $i); print $i; exit}}' | tr '[:upper:]' '[:lower:]')
fi

if [ -z "$ORIG_DST_MAC" ]; then
    echo "⚠️  Warning: Could not extract destination MAC from PCAP"
    echo "   Will rewrite all packets to use interface MAC"
    ORIG_DST_MAC="00:00:00:00:00:00"  # Dummy MAC for rewriting all
fi

echo "Original destination MAC in PCAP: $ORIG_DST_MAC"

if [ "$ORIG_DST_MAC" == "$IFACE_MAC" ]; then
    echo "✅ PCAP destination MAC already matches interface MAC. No rewrite needed."
    exit 0
fi

# Generate output filename if not provided
if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="${PCAP_FILE%.*}_rewritten_mac_${IFACE_MAC//:/_}.pcap"
fi

echo "Rewriting destination MAC: $ORIG_DST_MAC -> $IFACE_MAC"
echo "Output file: $OUTPUT_FILE"
echo ""

# Check if tcprewrite is available
if ! command -v tcprewrite &> /dev/null; then
    echo "❌ tcprewrite not found"
    echo "   Please install tcpreplay package: sudo apt-get install tcpreplay"
    exit 1
fi

echo "Using tcprewrite..."
# Rewrite destination MAC for all packets
# --enet-dmac sets destination MAC for all packets (no cache file needed for simple case)
tcprewrite --enet-dmac="$IFACE_MAC" --infile="$PCAP_FILE" --outfile="$OUTPUT_FILE" 2>&1 | grep -v "Warning" || true

if [ $? -eq 0 ] && [ -f "$OUTPUT_FILE" ]; then
    echo "✅ PCAP rewritten successfully"
    echo ""
    echo "Verifying rewrite..."
    NEW_DST_MAC=$(tcpdump -r "$OUTPUT_FILE" -n -c 1 -e 2>&1 | grep -oP '> \K[0-9a-f:]{17}' | head -1 | tr '[:upper:]' '[:lower:]')
    if [ -z "$NEW_DST_MAC" ]; then
        NEW_DST_MAC=$(tcpdump -r "$OUTPUT_FILE" -n -c 1 -e 2>&1 | awk '/ether/ {for(i=1;i<=NF;i++) if($i ~ /^[0-9a-f:]{17}$/ && $i ~ />/) {gsub(/>/, "", $i); print $i; exit}}' | tr '[:upper:]' '[:lower:]')
    fi
    if [ "$NEW_DST_MAC" == "$IFACE_MAC" ]; then
        echo "✅ Verification successful: destination MAC is now $NEW_DST_MAC"
    else
        echo "⚠️  Warning: Verification shows destination MAC is $NEW_DST_MAC (expected $IFACE_MAC)"
        echo "   This may be normal if PCAP has multiple different MAC addresses"
    fi
else
    echo "❌ Failed to rewrite PCAP"
    exit 1
fi

echo ""
echo "To use the rewritten PCAP:"
echo "  sudo ./test_ddos_detection.sh $IFNAME --pcap $OUTPUT_FILE"

