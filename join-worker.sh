#!/bin/bash
#
# This script joins a worker node to a Kubernetes cluster.
# It requires the full 'kubeadm join' command as an argument.
#
# It should be run on all worker nodes.
#
set -e

# Check if the join command was provided as an argument
if [ -z "$1" ]; then
    echo "Error: No join command provided."
    echo "Usage: ./join-worker.sh \"<your-kubeadm-join-command>\""
    exit 1
fi

JOIN_COMMAND=$1

echo "Joining the Kubernetes cluster..."

# Execute the provided join command with sudo
eval "$JOIN_COMMAND"

echo ""
echo "Worker node has been joined to the cluster successfully."
echo "You can verify its status by running 'kubectl get nodes' on the master node."