#!/bin/bash
#
# This script initializes the Kubernetes master node.
# It pulls the required images, runs kubeadm init, configures kubectl,
# and installs the Flannel CNI using Helm.
#
# !! This script should ONLY be run on the master node. !!
#
set -e

echo "Starting Kubernetes master node initialization..."

# 1. Pull the necessary container images for the control plane
echo "Step 1: Pulling control plane images..."
sudo kubeadm config images pull

# 2. Initialize the Kubernetes cluster with kubeadm
# The --pod-network-cidr is required for Flannel.
echo "Step 2: Initializing the cluster with kubeadm..."
sudo kubeadm init --upload-certs --pod-network-cidr=10.244.0.0/16

echo "----------------------------------------------------------------"
echo "IMPORTANT: A 'kubeadm join' command was printed above."
echo "You MUST copy and save this command to join your worker nodes."
echo "----------------------------------------------------------------"
sleep 10

# 3. Configure kubectl for the current user
echo "Step 3: Configuring kubectl..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 4. Install the Flannel CNI using Helm
echo "Step 4: Installing Flannel CNI..."
helm repo add flannel https://flannel-io.github.io/flannel/
helm install flannel --set podCidr="10.244.0.0/16" --create-namespace --namespace kube-flannel flannel/flannel

echo "Master node initialization is complete."
echo "Waiting a moment for the CNI to start..."
sleep 20

# 5. Verify the installation
echo "Step 5: Verifying the installation..."
echo "--- Flannel Pods ---"
kubectl get pods -n kube-flannel
echo ""
echo "--- Node Status ---"
kubectl get nodes -o wide

echo ""
echo "Your Kubernetes control plane is now ready."