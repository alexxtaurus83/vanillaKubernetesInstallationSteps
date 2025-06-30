#!/bin/bash
#
# This script installs the Kubernetes Metrics Server using the Bitnami Helm chart.
# It includes necessary arguments for kubeadm-based clusters.
#
# It should be run on the master node.
#
set -e

echo "Starting Kubernetes Metrics Server installation..."

# 1. Create a temporary Helm values file with required arguments
echo "Step 1: Creating Helm values file..."
VALUES_FILE="/tmp/values_metrics.yaml"
cat > "$VALUES_FILE" << EOL
apiService:
  create: true
extraArgs:
  - --kubelet-preferred-address-types=InternalIP
  - --kubelet-insecure-tls
EOL

echo "Values file created at $VALUES_FILE"

# 2. Add the Bitnami Helm repository
echo "Step 2: Adding Bitnami Helm repository..."
helm repo add bitnami https://charts.bitnami.com/bitnami

# 3. Install the metrics-server chart with the custom values
echo "Step 3: Installing Metrics Server..."
helm upgrade --install metrics-server bitnami/metrics-server -f "$VALUES_FILE"

echo "Metrics Server installation is complete."
echo "It may take a minute for the server to start collecting data."
echo "You can verify by running 'kubectl top nodes' or 'kubectl top pods -A'."