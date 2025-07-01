#!/bin/bash

# This script upgrades the Kubernetes worker node components.
# It expects the node to be drained *before* running this script.

if [ -z "$1" ]; then
  echo "Usage: $0 <worker_node_hostname>"
  exit 1
fi

NODE_HOSTNAME=$1
declare -a versions=("1.31.10-1.1" "1.32.5-1.1" "1.33.2-1.1")

for version in "${versions[@]}"; do
  echo -e "\n🚀 Upgrading Worker Node $NODE_HOSTNAME to Kubernetes $version"

  echo "🔹 Installing kubelet and kubectl $version"
  sudo apt-mark unhold kubelet kubectl
  sudo apt-get install -y kubelet=$version kubectl=$version
  sudo apt-mark hold kubelet kubectl

  echo "🔹 Restarting kubelet"
  sudo systemctl daemon-reexec
  sudo systemctl restart kubelet

  echo "✅ Worker node $NODE_HOSTNAME upgrade to $version complete!"
done

echo "Note: Remember to uncordon the worker node from the master after upgrade."