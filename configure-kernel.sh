#!/bin/bash
#
# This script configures necessary kernel modules and sysctl parameters
# for container runtimes and Kubernetes networking.
# It should be run on all master and worker nodes.
#
set -e

echo "Configuring kernel modules and parameters..."

# --- Kernel Module Configuration ---
echo "Step 1: Configuring kernel modules..."

# Define the kernel modules to be loaded
MODULES_CONFIG_FILE="/etc/modules-load.d/containerd.conf"
MODULES="overlay\nbr_netfilter"

# Create the configuration file to ensure modules are loaded on system boot.
echo -e "$MODULES" | sudo tee "$MODULES_CONFIG_FILE" > /dev/null
echo "Created $MODULES_CONFIG_FILE to load modules on boot."

# Load the modules into the running kernel immediately.
echo "Loading overlay module..."
sudo modprobe overlay
echo "Loading br_netfilter module..."
sudo modprobe br_netfilter

echo "Kernel modules configured and loaded."

# --- Sysctl Parameter Configuration ---
echo "Step 2: Configuring kernel parameters..."

# Define the sysctl parameters for Kubernetes
SYSCTL_CONFIG_FILE="/etc/sysctl.d/kubernetes.conf"
SYSCTL_PARAMS="net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1"

# Create the sysctl configuration file to persist settings across reboots.
echo -e "$SYSCTL_PARAMS" | sudo tee "$SYSCTL_CONFIG_FILE" > /dev/null
echo "Created $SYSCTL_CONFIG_FILE with Kubernetes networking parameters."

# Apply the sysctl parameters immediately without a reboot.
echo "Applying sysctl parameters..."
sudo sysctl --system

echo "Kernel parameters configured and applied successfully."