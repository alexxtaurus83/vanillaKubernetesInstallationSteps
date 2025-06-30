#!/bin/bash
#
# This script creates the necessary Kubernetes resources to allow
# cert-manager to authenticate with Vault and issue certificates.
#
# It should be run on the master node after Vault has been initialized.
#
set -e

echo "Configuring cert-manager to use Vault..."

# 1. Create a ServiceAccount for cert-manager to use when authenticating to Vault
echo "Step 1: Creating 'issuer' ServiceAccount in 'cert-manager' namespace..."
kubectl create serviceaccount issuer -n cert-manager

# 2. Create a token Secret for the ServiceAccount
# This token will be presented to Vault for authentication.
echo "Step 2: Creating token Secret for 'issuer' ServiceAccount..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: issuer-token
  namespace: cert-manager
  annotations:
    kubernetes.io/service-account.name: issuer
type: kubernetes.io/service-account-token
EOF

# 3. Create the ClusterIssuer resource
# This tells cert-manager how to connect to Vault and which role to use.
echo "Step 3: Creating 'vault-issuer' ClusterIssuer..."
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: vault-issuer
  namespace: cert-manager
spec:
  vault:
    server: http://vault.vault.svc.cluster.local:8200
    path: pki/sign/svhome-dot-net
    auth:
      kubernetes:
        mountPath: /v1/auth/kubernetes
        role: issuer
        secretRef:
          name: issuer-token
          key: token
EOF

echo "Waiting a moment for the issuer to be configured..."
sleep 10

# 4. Verify the issuer status
echo "Step 4: Verifying issuer status..."
kubectl describe clusterissuers.cert-manager.io vault-issuer

echo ""
echo "Vault issuer configured successfully. It should report as Ready."