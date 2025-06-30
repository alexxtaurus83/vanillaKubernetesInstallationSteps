#!/bin/bash
#
# This script creates a cStor storage pool and a corresponding StorageClass.
# It then sets the new StorageClass as the default for the cluster.
#
# It should be run on the master node after OpenEBS has been installed.
#
set -e

echo "Starting OpenEBS cStor Pool and StorageClass creation..."

# 1. Apply the CStorPoolCluster and StorageClass YAML
# IMPORTANT: The blockDeviceName values must match those discovered by OpenEBS.
# The user should verify these before running the script.
echo "Step 1: Creating CStorPoolCluster and StorageClass..."
cat << EOF | kubectl apply -f -
apiVersion: cstor.openebs.io/v1
kind: CStorPoolCluster
metadata:
  name: cstor-disk-pool
  namespace: openebs
spec:
  pools:
    - nodeSelector:
        kubernetes.io/hostname: "k8sworker01.svhome.net"
      dataRaidGroups:
        - blockDevices:
            - blockDeviceName: "blockdevice-604ad6145699fc5c74640480aa3b2c73"
      poolConfig:
        dataRaidGroupType: "stripe"

    - nodeSelector:
        kubernetes.io/hostname: "k8sworker02.svhome.net"
      dataRaidGroups:
        - blockDevices:
            - blockDeviceName: "blockdevice-d5e958ddadc9699297b21e896e634058"
      poolConfig:
        dataRaidGroupType: "stripe"
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: cstor-csi-disk
provisioner: cstor.csi.openebs.io
allowVolumeExpansion: true
parameters:
  cas-type: cstor
  cstorPoolCluster: cstor-disk-pool
  replicaCount: "2"
EOF

echo "Resources created. Waiting a moment for them to initialize..."
sleep 15

# 2. Set the new StorageClass as the default
echo "Step 2: Setting 'cstor-csi-disk' as the default StorageClass..."
kubectl patch storageclass cstor-csi-disk -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "Default StorageClass has been set."

# 3. Verify the setup
echo "Step 3: Verifying the setup..."
echo "--- StorageClass ---"
kubectl get sc
echo ""
echo "--- CStorPoolCluster Status ---"
kubectl get cspc -n openebs

echo ""
echo "OpenEBS cStor pool and StorageClass have been configured successfully."
echo "You can now create PersistentVolumeClaims."