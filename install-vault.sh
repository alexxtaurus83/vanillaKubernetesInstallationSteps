#!/bin/bash
#
# This script installs HashiCorp Vault using the official Helm chart.
# It configures persistent storage and an Ingress for the UI.
#
# It should be run on the master node.
#
set -e

# --- Configuration ---
VAULT_HOSTNAME="vault.svhome.net"
# ---

echo "Starting HashiCorp Vault installation..."

# 1. Add the HashiCorp Helm repository
echo "Step 1: Adding HashiCorp Helm repository..."
helm repo add hashicorp https://helm.releases.hashicorp.com

# 2. Install the Vault chart
echo "Step 2: Installing Vault Helm chart..."
helm upgrade --install vault hashicorp/vault --create-namespace -n vault \
  --set "injector.enabled=false" \
  --set "dataStorage.enabled=true" \
  --set "dataStorage.size=5Gi" \
  --set "dataStorage.storageClass=cstor-csi-disk" \
  --set "ui.enabled=true" \
  --set "server.ingress.enabled=true" \
  --set "server.ingress.ingressClassName=nginx" \
  --set "server.ingress.hosts[0].host=$VAULT_HOSTNAME"

# 3. Wait for the Vault pod to be ready
echo "Step 3: Waiting for Vault pod to be ready..."
kubectl wait --namespace vault \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=vault \
  --timeout=300s

echo ""
echo "Vault has been installed successfully."
echo "The UI is available at http://$VAULT_HOSTNAME"
echo "Next, you MUST initialize and configure Vault by following the guide."