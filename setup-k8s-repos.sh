#!/bin/bash

# This script sets up Kubernetes APT repositories for specified versions.

for version in v1.31 v1.32 v1.33; do
  echo "Setting up Kubernetes $version repo..."

  # Create keyring directory
  sudo mkdir -p /etc/apt/keyrings

  # Download and store the GPG key
  curl -fsSL https://pkgs.k8s.io/core:/stable:/$version/deb/Release.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring-$version.gpg

  # Add the APT source
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring-$version.gpg] https://pkgs.k8s.io/core:/stable:/$version/deb/ /" \
    | sudo tee /etc/apt/sources.list.d/kubernetes-$version.list > /dev/null
done

sudo apt update