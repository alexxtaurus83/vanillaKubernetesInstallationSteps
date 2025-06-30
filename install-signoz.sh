#!/bin/bash
#
# This script installs SigNoz, an open-source observability platform.
# It configures an Ingress resource to expose the UI securely
# with a TLS certificate from the 'vault-issuer'.
#
# It should be run on the master node.
#
set -e

# --- Configuration ---
# IMPORTANT: Change this to the desired hostname for your dashboard.
# You must create a DNS A record pointing this hostname to your
# NGINX Ingress Controller's external IP address.
SIGNOZ_HOSTNAME="signoz.svhome.net"
# ---

echo "Starting SigNoz installation for host: $SIGNOZ_HOSTNAME"

# 1. Add the SigNoz Helm repository
echo "Step 1: Adding SigNoz Helm repository..."
helm repo add signoz https://charts.signoz.io

# 2. Install the SigNoz chart
echo "Step 2: Installing the SigNoz Helm chart..."
helm upgrade --install signoz signoz/signoz --namespace platform --create-namespace \
  --set persistence.enabled=true \
  --set persistence.storageClass=cstor-csi-disk \
  --set frontend.ingress.annotations."cert-manager\.io\/cluster-issuer"=vault-issuer \
  --set frontend.ingress.enabled=true \
  --set frontend.ingress.className=nginx \
  --set frontend.ingress.hosts[0].host=$SIGNOZ_HOSTNAME \
  --set frontend.ingress.hosts[0].paths[0].path=/ \
  --set frontend.ingress.hosts[0].paths[0].pathType=ImplementationSpecific \
  --set frontend.ingress.tls[0].secretName=signoz-tls \
  --set frontend.ingress.tls[0].hosts[0]=$SIGNOZ_HOSTNAME \
  --set k8s-infra.insecureSkipVerify=true

echo ""
echo "SigNoz installation complete."
echo "It will be available at: https://$SIGNOZ_HOSTNAME"
echo "Note: It may take a few minutes for all components to become active."