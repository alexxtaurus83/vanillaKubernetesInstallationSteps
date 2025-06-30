#!/bin/bash
#
# This script installs the Kubernetes Dashboard using Helm.
# It configures an Ingress resource to expose the dashboard securely
# with a TLS certificate from cert-manager.
#
# It should be run on the master node.
#
set -e

# --- Configuration ---
# IMPORTANT: Change this to the desired hostname for your dashboard.
# You must create a DNS A record pointing this hostname to your
# NGINX Ingress Controller's external IP address.
DASHBOARD_HOSTNAME="dash.svhome.net"
# ---

echo "Starting Kubernetes Dashboard installation for host: $DASHBOARD_HOSTNAME"

# 1. Add the Kubernetes Dashboard Helm repository
echo "Step 1: Adding Kubernetes Dashboard Helm repository..."
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

# 2. Install the dashboard chart with Ingress enabled
echo "Step 2: Installing the dashboard Helm chart..."
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --version 7.6.1 \
  --create-namespace \
  --namespace kubernetes-dashboard \
  --set app.ingress.enabled=true \
  --set app.ingress.hosts={$DASHBOARD_HOSTNAME} \
  --set app.ingress.issuer.name=test-ca-cluster-issuer \
  --set app.ingress.secretName=kubernetesdashboard-cert \
  --set app.ingress.issuer.scope=cluster \
  --set ingress.annotations."kubernetes\.io\/ingress\.class"=nginx \
  --set app.ingress.ingressClassName=nginx \
  --set nginx.enabled=false \
  --set cert-manager.enabled=false \
  --set metrics-server.enabled=false

echo ""
echo "Kubernetes Dashboard installation complete."
echo "It will be available at: https://$DASHBOARD_HOSTNAME"
echo ""
echo "IMPORTANT: An admin user is required to log in."
echo "You will need to create a ServiceAccount and ClusterRoleBinding, then get a token."
echo "Example command to create an admin user:"
echo "kubectl create serviceaccount -n kubernetes-dashboard admin-user"
echo "kubectl create clusterrolebinding -n kubernetes-dashboard admin-user --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:admin-user"
echo "kubectl -n kubernetes-dashboard create token admin-user"