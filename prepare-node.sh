#!/bin/bash
#
# This script prepares a new Ubuntu 22.04 node for Kubernetes installation.
# It should be run on all master and worker nodes.
#
set -e

echo "Starting node preparation..."

# 1. Update package lists and perform a full system upgrade
echo "Updating and upgrading system packages..."
sudo apt-get update
sudo apt-get -y full-upgrade

# 2. Install prerequisite packages for Kubernetes and utilities
echo "Installing prerequisite packages..."
sudo apt-get -y install \
    curl \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    qemu-guest-agent

# 3. Start and enable the QEMU guest agent for Proxmox integration
echo "Configuring QEMU guest agent..."
sudo systemctl start qemu-guest-agent
sudo systemctl enable qemu-guest-agent

echo "Node preparation complete."
echo "It is recommended to reboot the system now."