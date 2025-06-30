#!/bin/bash
#
# This script installs and configures the containerd runtime.
# It uses the official Docker repository to get a stable version of containerd,
# configures it to use the systemd cgroup driver, and enables the service.
# It should be run on all master and worker nodes.
#
set -e

echo "Starting containerd installation and configuration..."

# 1. Add Docker's official GPG key
echo "Step 1: Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 2. Add the Docker repository to Apt sources
echo "Step 2: Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3. Update package lists and install containerd
echo "Step 3: Installing containerd.io..."
sudo apt-get update
sudo apt-get install -y containerd.io

# 4. Generate default containerd configuration and enable systemd cgroup driver
echo "Step 4: Configuring containerd..."
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# 5. Restart and enable the containerd service
echo "Step 5: Restarting and enabling containerd service..."
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "containerd has been installed and configured successfully."