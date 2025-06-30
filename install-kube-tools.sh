#!/bin/bash
#
# This script installs the Kubernetes command-line tools:
# kubelet, kubeadm, and kubectl.
# It should be run on all master and worker nodes.
#
set -e

echo "Starting Kubernetes tools installation..."

# 1. Add the Kubernetes GPG key
echo "Step 1: Adding Kubernetes GPG key..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# 2. Add the Kubernetes apt repository
echo "Step 2: Adding Kubernetes repository..."
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 3. Update package lists
echo "Step 3: Updating package lists..."
sudo apt-get update

# 4. Install kubelet, kubeadm, and kubectl
echo "Step 4: Installing kubelet, kubeadm, and kubectl..."
sudo apt-get install -y kubelet kubeadm kubectl

# 5. Hold the packages at their current version
echo "Step 5: Holding Kubernetes packages to prevent automatic updates..."
sudo apt-mark hold kubelet kubeadm kubectl

echo "Kubernetes tools have been installed and held successfully."