#!/bin/bash
#
# This script installs the NGINX Ingress Controller.
# It applies the official manifests and waits for the controller to be ready.
#
# It should be run on the master node.
#
set -e

echo "Starting NGINX Ingress Controller installation..."

# 1. Apply the official deployment YAML.
# This includes the controller deployment and a LoadBalancer service
# that MetalLB will provide an IP for.
echo "Step 1: Applying NGINX Ingress Controller manifests..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/cloud/deploy.yaml

# 2. Wait for the Ingress controller pods to be ready.
echo "Step 2: Waiting for controller pods to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

# 3. Scale the deployment to 2 replicas for high availability (optional)
echo "Step 3: Scaling controller deployment to 2 replicas..."
kubectl -n ingress-nginx scale deployment ingress-nginx-controller --replicas 2


# 4. Display the external IP address assigned by MetalLB
echo "Step 4: Fetching the external IP address..."
EXTERNAL_IP=$(kubectl get service ingress-nginx-controller --namespace=ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo ""
echo "NGINX Ingress Controller installed successfully."
echo "It is available at the external IP: $EXTERNAL_IP"
echo "Point your DNS records for Ingress hosts to this IP."