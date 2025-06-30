#!/bin/bash
#
# This script installs k9s, a terminal-based UI for Kubernetes.
# It uses snap for the installation.
#
# It should be run on the master node or your local workstation.
#
set -e

echo "Starting k9s installation..."

# 1. Check if snap is installed
if ! command -v snap &> /dev/null
then
    echo "Error: snap could not be found. Please install snapd first."
    exit 1
fi

# 2. Install k9s using snap
echo "Step 1: Installing k9s via snap..."
sudo snap install k9s

# 3. Create a symbolic link for easier access
# This allows running 'k9s' directly instead of the full path.
echo "Step 2: Creating symbolic link in /usr/local/bin/..."
if [ ! -f "/usr/local/bin/k9s" ]; then
    sudo ln -s /snap/k9s/current/bin/k9s /usr/local/bin/k9s
fi

echo ""
echo "k9s has been installed successfully."
echo "You can now run it by typing 'k9s' in your terminal."