#!/bin/bash
#
# This script installs and configures MetalLB for a bare-metal Kubernetes cluster.
# It should be run on the master node.
#
set -e

echo "Starting MetalLB installation and configuration..."

# 1. Find the latest MetalLB version and apply the installation manifests
echo "Step 1: Installing MetalLB..."
MetalLB_RTAG=$(curl -s https://api.github.com/repos/metallb/metallb/releases/latest | grep tag_name | cut -d '"' -f 4)
if [ -z "$MetalLB_RTAG" ]; then
    echo "Error: Could not determine latest MetalLB version."
    exit 1
fi
echo "Latest MetalLB version is $MetalLB_RTAG"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${MetalLB_RTAG}/config/manifests/metallb-native.yaml

# 2. Wait for MetalLB pods to be ready
echo "Step 2: Waiting for MetalLB pods to be ready..."
kubectl wait --namespace metallb-system \
                --for=condition=ready pod \
                --selector=app=metallb \
                --timeout=300s

echo "MetalLB pods are running."

# 3. Apply the IP Address Pool and L2 Advertisement configuration
echo "Step 3: Configuring MetalLB IP address pool..."
# IMPORTANT: The IP address range here is an example.
# Users should change this to a free range on their own network.
kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: production
  namespace: metallb-system
spec:
  addresses:
  - 192.168.86.251-192.168.86.253
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-advert
  namespace: metallb-system
EOF

echo "MetalLB configuration applied."

# 4. Verify the configuration
echo "Step 4: Verifying configuration..."
echo "--- IPAddressPool ---"
kubectl get ipaddresspools.metallb.io -n metallb-system
echo ""
echo "--- L2Advertisement ---"
kubectl get l2advertisements.metallb.io -n metallb-system

echo ""
echo "MetalLB has been installed and configured successfully."
echo "You can now create services of type 'LoadBalancer'."