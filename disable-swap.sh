#!/bin/bash
#
# This script disables swap on a Linux system.
# This is a prerequisite for the Kubernetes kubelet.
# It should be run on all master and worker nodes.
#
set -e

echo "Disabling swap..."

# 1. Turn off all swap devices immediately.
if [ "$(swapon -s)" ]; then
    sudo swapoff -a
    echo "Swap has been turned off for the current session."
else
    echo "Swap is already off."
fi

# 2. Remove swap entries from /etc/fstab to persist the change across reboots.
# This command finds lines containing '\tswap\t' and deletes them.
if grep -q '\sswap\s' /etc/fstab; then
    sudo sed -i '/\sswap\s/d' /etc/fstab
    echo "Swap entries removed from /etc/fstab."
else
    echo "No swap entries found in /etc/fstab."
fi

echo "Swap has been permanently disabled."