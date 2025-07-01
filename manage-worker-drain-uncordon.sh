#!/bin/bash

# This script helps manage draining and uncordoning worker nodes for upgrades.

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <action> <worker_node_hostname>"
  echo "Actions: drain, uncordon"
  exit 1
fi

ACTION=$1
NODE_HOSTNAME=$2

case "$ACTION" in
  drain)
    echo "Draining worker node: $NODE_HOSTNAME"
    kubectl drain "$NODE_HOSTNAME" --ignore-daemonsets --delete-emptydir-data --force
    echo "Worker node $NODE_HOSTNAME drained. Now upgrade components on $NODE_HOSTNAME."
    ;;
  uncordon)
    echo "Uncordoning worker node: $NODE_HOSTNAME"
    kubectl uncordon "$NODE_HOSTNAME"
    echo "Worker node $NODE_HOSTNAME uncordoned."
    ;;
  *)
    echo "Invalid action. Please use 'drain' or 'uncordon'."
    exit 1
    ;;
esac