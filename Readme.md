# Complete Guide: Deploying a Kubernetes Cluster on Proxmox

This document provides a comprehensive, step-by-step guide to deploying a production-ready Kubernetes cluster on Proxmox VE. It covers everything from initial VM setup to advanced topics like persistent storage, load balancing, certificate management, and observability.

## Part 1: Initial Node and Cluster Setup

This part covers the foundational steps of creating the virtual machines, preparing the operating system, and installing the core Kubernetes components.

### 1. DNS Configuration
Before deploying the virtual machines, configure DNS `A` records for each node to ensure proper name resolution.

| IP Address | Hostname |
| :--- | :--- |
| `192.168.86.32` | `k8smaster.svhome.net` |
| `192.168.86.37` | `k8sworker01.svhome.net` |
| `192.168.86.26` | `k8sworker02.svhome.net` |

### 2. Proxmox Virtual Machine Deployment
Deploy three virtual machines (one master, two workers) using the configurations provided in the initial notes. Ensure the master has 4+ cores and 8GB+ RAM, and the workers have 8+ cores, 16GB+ RAM, and two separate virtual disks (e.g., 70G for the OS, 100G for storage).

### 3. Operating System Installation
Install **Ubuntu Server 22.04 LTS (Jammy Jellyfish)** on all three VMs. During installation, configure the static IPs from Step 1 and install the OpenSSH server.

### 4. System Preparation (All Nodes)
Run the `prepare-node.sh` script on all three nodes to update packages and install prerequisites like `qemu-guest-agent`.

### 5. Disable Swap (All Nodes)
Run the `disable-swap.sh` script on all nodes. Kubernetes requires swap to be disabled for performance and stability.

### 6. Configure Kernel Parameters (All Nodes)
Run the `configure-kernel.sh` script on all nodes to load the `overlay` and `br_netfilter` modules and set required `sysctl` parameters for container networking.

### 7. Install Container Runtime (All Nodes)
Run the `install-containerd.sh` script on all nodes to install and configure the `containerd` runtime.

### 8. Install Kubernetes Components (All Nodes)
Run the `install-kube-tools.sh` script on all nodes to install `kubelet`, `kubeadm`, and `kubectl` and hold them at their current version.

### 9. Initialize the Master Node (Master Node Only)
Run the `initialize-master.sh` script on the master node. This will set up the control plane and output a `kubeadm join` command. **Copy and save this command.**

### 10. Join Worker Nodes to the Cluster (Worker Nodes Only)
Run the `join-worker.sh` script on both worker nodes, passing the saved `kubeadm join` command as an argument to connect them to the cluster.

## Part 2: Cluster Services and Add-ons

This part covers the installation of essential services for load balancing, storage, certificate management, and monitoring.

### 11. Install MetalLB (Master Node)
Run the `install-metallb.sh` script to provide network load-balancer functionality for your bare-metal cluster, allowing you to create services of type `LoadBalancer`.

### 12. Install and Configure OpenEBS (Master Node)
First, run `install-openebs.sh` to deploy the OpenEBS storage provider. Then, run `create-cstor-pool.sh` to create a storage pool from the extra disks on your worker nodes and set up a default `StorageClass` for persistent volume claims.

### 13. Install Metrics Server (Master Node)
Run the `install-metrics-server.sh` script to deploy the Kubernetes Metrics Server, which enables resource monitoring with commands like `kubectl top node`.

### 14. Install Cert-Manager (Master Node)
Run the `install-cert-manager.sh` script to install the certificate management controller and configure a basic self-signed issuer.

### 15. Install NGINX Ingress Controller (Master Node)
Run the `install-ingress-nginx.sh` script to deploy the NGINX Ingress Controller, which will manage external access to your cluster's HTTP/S services.

### 16. Install and Configure HashiCorp Vault (Master Node)
For a production-grade PKI, install and configure Vault to act as a private Certificate Authority.
1.  Run `install-vault.sh` to deploy Vault.
2.  Follow the manual steps in the guide to **initialize, unseal, and configure the PKI engine** inside the Vault pod. This is a critical, one-time manual step.
3.  Run `configure-vault-issuer.sh` to create a `ClusterIssuer` that connects `cert-manager` to Vault.
4.  Run `upgrade-vault-ingress.sh` to secure the Vault UI with a certificate from its own PKI.
5.  Run `install-vault-autounseal.sh` to install the vault-autounseal helper and configure it to automatically unseal the Vault pod.
6.  Run `run-inside-valut.commands` to initialize and configure the PKI engine inside the Vault pod.

## Part 3: User Interfaces and Management Tools

This part covers the installation of web UIs and terminal tools to make managing the cluster easier.

### 17. Install Kubernetes Dashboard (Master Node)
1.  Run the `install-dashboard.sh` script to deploy the official Kubernetes Dashboard.
2.  Run the `create-dashboard-admin.sh` script to create a service account with admin privileges and retrieve a login token.

### 18. Install Optional Management Tools (Master Node)
1.  Run `install-k9s.sh` to install the popular terminal-based UI.
2.  Run `install-helm-dashboard.sh` to deploy a web UI specifically for managing Helm releases.
3.  Run `install-portainer.sh` to deploy an alternative, operator-friendly web UI.

## Part 4: Observability with OpenTelemetry and SigNoz

This part covers setting up a complete observability stack to monitor the health and performance of your cluster and applications.

### 19. Install SigNoz (Master Node)
Run the `install-signoz.sh` script to deploy SigNoz, the all-in-one backend for your metrics, traces, and logs.

### 20. Install OpenTelemetry Collectors (Master Node)
Run the `install-otel-collectors.sh` script to deploy OTel collectors as both a DaemonSet and a Deployment to gather telemetry data from across the cluster.

### 21. Install OpenTelemetry Operator (Master Node)
Run the `install-otel-operator.sh` script to enable automatic instrumentation of your applications for distributed tracing.

### 22. Test with the OpenTelemetry Demo (Master Node)
Run the `install-otel-demo.sh` script to deploy a sample microservices application. This will generate data you can explore in the SigNoz UI to verify your observability stack is working correctly.