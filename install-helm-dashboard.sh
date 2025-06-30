#!/bin/bash
#
# This script installs the Helm Dashboard UI.
# It configures an Ingress resource to expose the dashboard securely
# with a TLS certificate from the 'test-ca-cluster-issuer'.
#
# It should be run on the master node.
#
set -e

# --- Configuration ---
# IMPORTANT: Change this to the desired hostname for your dashboard.
# You must create a DNS A record pointing this hostname to your
# NGINX Ingress Controller's external IP address.
HELM_DASHBOARD_HOSTNAME="helmboard.svhome.net"
# ---

echo "Starting Helm Dashboard installation for host: $HELM_DASHBOARD_HOSTNAME"

# 1. Add the Komodorio Helm repository
echo "Step 1: Adding Komodorio Helm repository..."
helm repo add komodorio https://helm-charts.komodor.io

# 2. Install the helm-dashboard chart with Ingress enabled
echo "Step 2: Installing the helm-dashboard Helm chart..."
helm upgrade --install helm-dashboard komodorio/helm-dashboard \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.annotations."cert-manager\.io/cluster-issuer"=test-ca-cluster-issuer \
  --set ingress.hosts[0].host=$HELM_DASHBOARD_HOSTNAME \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=ImplementationSpecific \
  --set ingress.tls[0].secretName=helmboard-tls \
  --set ingress.tls[0].hosts[0]=$HELM_DASHBOARD_HOSTNAME \
  --set dashboard.persistence.enabled=false

echo ""
echo "Helm Dashboard installation complete."
echo "It will be available at: https://$HELM_DASHBOARD_HOSTNAME"
echo "Note: It may take a minute for the ingress and certificate to become active."