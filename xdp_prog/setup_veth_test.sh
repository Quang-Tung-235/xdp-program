#!/bin/bash
# Setup veth pair for testing PCAP files with XDP
# This allows testing without affecting real network interface
# 
# Usage: ./setup_veth_test.sh [server_ip] [client_ip]
# Default: server=192.168.50.4, client=192.168.50.5

VETH_CLIENT="veth_test_client"
VETH_SERVER="veth_test_server"
SERVER_IP=${1:-"192.168.50.4"}
CLIENT_IP=${2:-"192.168.50.5"}

# Cleanup existing veth if exists
echo "Cleaning up existing veth interfaces..."
sudo ip link delete $VETH_CLIENT 2>/dev/null || true
sudo ip link delete $VETH_SERVER 2>/dev/null || true
sleep 1

echo "Creating veth pair: $VETH_CLIENT <-> $VETH_SERVER"
sudo ip link add $VETH_CLIENT type veth peer name $VETH_SERVER

# Set IP addresses
echo "Configuring IP addresses..."
sudo ip addr add ${SERVER_IP}/24 dev $VETH_SERVER
sudo ip addr add ${CLIENT_IP}/24 dev $VETH_CLIENT

# Bring interfaces up
echo "Bringing interfaces up..."
sudo ip link set $VETH_CLIENT up
sudo ip link set $VETH_SERVER up

# Add ARP entries to avoid neighbor discovery delays
echo "Adding ARP entries..."
CLIENT_MAC=$(ip link show $VETH_CLIENT | grep -oP 'link/ether \K[^ ]+')
SERVER_MAC=$(ip link show $VETH_SERVER | grep -oP 'link/ether \K[^ ]+')
sudo ip neigh add $CLIENT_IP lladdr $CLIENT_MAC dev $VETH_SERVER nud permanent 2>/dev/null || true
sudo ip neigh add $SERVER_IP lladdr $SERVER_MAC dev $VETH_CLIENT nud permanent 2>/dev/null || true

# Disable offloading features that might interfere
echo "Disabling offloading features..."
sudo ethtool -K $VETH_CLIENT tx off rx off 2>/dev/null || true
sudo ethtool -K $VETH_SERVER tx off rx off 2>/dev/null || true

echo ""
echo "✅ Veth pair created successfully:"
echo "   $VETH_CLIENT: $CLIENT_IP"
echo "   $VETH_SERVER: $SERVER_IP"
echo ""
echo "📌 IMPORTANT: XDP should be attached to $VETH_SERVER"
echo "   Traffic from $VETH_CLIENT will be seen by XDP on $VETH_SERVER"
echo ""
echo "To test with PCAP:"
echo "  # 1. Setup veth (this script)"
echo "  sudo ./setup_veth_test.sh"
echo ""
echo "  # 2. Load XDP on veth_server"
echo "  sudo ./test_ddos_detection.sh $VETH_SERVER --pcap ~/Downloads/200attack.pcap"
echo ""
echo "  # Or manually:"
echo "  sudo ./xdp_loader -d $VETH_SERVER"
echo "  sudo python3 read_model_to_map.py ... /sys/fs/bpf/$VETH_SERVER/svm_map"
echo "  sudo tcpreplay --intf1=$VETH_CLIENT --mtu-truncate ~/Downloads/200attack.pcap"
echo ""
echo "To cleanup:"
echo "  sudo ip link delete $VETH_CLIENT"
