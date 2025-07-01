#!/bin/bash

# This script upgrades the Kubernetes master node components.

declare -a versions=("1.31.10-1.1" "1.32.5-1.1" "1.33.2-1.1")

# Ensure kubectl admin config is setup if not already
kubectl create clusterrolebinding kubernetes-admin-binding \
  --clusterrole=cluster-admin \
  --user=kubernetes-admin

for version in "${versions[@]}"; do
  echo -e "\n🚀 Upgrading Master Node to Kubernetes $version"

  echo "🔹 Installing kubeadm $version"
  sudo apt-mark unhold kubeadm
  sudo apt-get install -y kubeadm=$version
  sudo apt-mark hold kubeadm

  echo "🔹 Running kubeadm upgrade apply v${version%-*}"
  # The -y is important for non-interactive upgrade
  sudo kubeadm upgrade apply v${version%-*} -y

  echo "🔹 Installing kubelet and kubectl $version"
  sudo apt-mark unhold kubelet kubectl
  sudo apt-get install -y kubelet=$version kubectl=$version
  sudo apt-mark hold kubelet kubectl

  echo "🔹 Restarting kubelet"
  sudo systemctl daemon-reexec
  sudo systemctl restart kubelet

  echo "✅ Master node upgrade to $version complete!"
done

echo "Final check for kubectl cluster-info"
kubectl cluster-info