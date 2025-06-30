#!/bin/bash
#
# This script installs cert-manager and configures a self-signed
# Certificate Authority (CA) and a ClusterIssuer to sign certificates.
#
# It should be run on the master node.
#
set -e

echo "Starting cert-manager installation..."

# 1. Add the Jetstack Helm repository
echo "Step 1: Adding Jetstack Helm repository..."
helm repo add jetstack https://charts.jetstack.io

# 2. Install the cert-manager chart
echo "Step 2: Installing cert-manager Helm chart..."
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true \
  --set prometheus.enabled=false

# 3. Wait for cert-manager pods to be ready
echo "Step 3: Waiting for cert-manager pods to be ready..."
kubectl --timeout=120s wait --for=condition=Ready pods --all --namespace cert-manager

echo "cert-manager pods are ready."

# 4. Create the self-signed CA and ClusterIssuer
echo "Step 4: Creating self-signed CA and ClusterIssuer..."
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-cluster-issuer
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: test-ca
  namespace: cert-manager
spec:
  isCA: true
  commonName: test-ca
  secretName: test-ca
  issuerRef:
    name: selfsigned-cluster-issuer
    kind: ClusterIssuer
    group: cert-manager.io
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: test-ca-cluster-issuer
spec:
  ca:
    secretName: test-ca
EOF

echo "Self-signed ClusterIssuer 'test-ca-cluster-issuer' created successfully."
echo "You can now create Certificate resources using this issuer."