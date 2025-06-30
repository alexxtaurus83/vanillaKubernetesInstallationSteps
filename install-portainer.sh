#!/bin/bash
#
# This script installs Portainer, a management UI for Kubernetes.
# It configures an Ingress resource to expose the dashboard securely
# with a TLS certificate from the 'test-ca-cluster-issuer' and enables persistence.
#
# It should be run on the master node.
#
set -e

# --- Configuration ---
# IMPORTANT: Change this to the desired hostname for your dashboard.
# You must create a DNS A record pointing this hostname to your
# NGINX Ingress Controller's external IP address.
PORTAINER_HOSTNAME="portainer.svhome.net"
# ---

echo "Starting Portainer installation for host: $PORTAINER_HOSTNAME"

# 1. Add the Portainer Helm repository
echo "Step 1: Adding Portainer Helm repository..."
helm repo add portainer https://portainer.github.io/k8s/

# 2. Install the Portainer chart
echo "Step 2: Installing the Portainer Helm chart..."
helm install portainer portainer/portainer -n portainer --create-namespace \
  --set service.type=ClusterIP \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.annotations."cert-manager\.io\/cluster-issuer"=test-ca-cluster-issuer \
  --set ingress.hosts[0].host=$PORTAINER_HOSTNAME \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.tls[0].secretName=portainer-tls \
  --set ingress.tls[0].hosts[0]=$PORTAINER_HOSTNAME \
  --set persistence.enabled=true \
  --set persistence.size=2Gi \
  --set persistence.storageClass=cstor-csi-disk

echo ""
echo "Portainer installation complete."
echo "It will be available at: https://$PORTAINER_HOSTNAME"
echo "On first access, you will be prompted to create an admin user."