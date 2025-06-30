#!/bin/bash
#
# This script installs OpenEBS with the cStor engine using Helm.
# It should be run on the master node.
#
set -e

echo "Starting OpenEBS installation..."

# 1. Add the OpenEBS Helm repository
echo "Step 1: Adding OpenEBS Helm repository..."
helm repo add openebs https://openebs.github.io/charts

# 2. Install the OpenEBS chart with the cStor engine enabled
echo "Step 2: Installing OpenEBS chart (this may take a few minutes)..."
helm install openebs --namespace openebs openebs/openebs --set cstor.enabled=true --create-namespace

# 3. Wait for OpenEBS pods to be ready
echo "Step 3: Waiting for OpenEBS pods to be ready..."
# This is a basic check. A more robust check would look at all deployments.
kubectl wait --namespace openebs \
                --for=condition=ready pod \
                --selector=app=openebs \
                --timeout=5m

echo "OpenEBS pods are running."
echo "It may take another minute for block devices to be discovered."
sleep 60

# 4. Verify the installation by checking for discovered block devices
echo "Step 4: Verifying block device discovery..."
kubectl get bd -n openebs

echo ""
echo "OpenEBS has been installed successfully."
echo "You can now create cStor Storage Pools and Persistent Volumes."