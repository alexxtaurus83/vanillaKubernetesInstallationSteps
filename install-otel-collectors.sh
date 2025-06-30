#!/bin/bash
#
# This script installs the OpenTelemetry Collector in two modes:
# 1. A DaemonSet for node-local data (logs, host metrics).
# 2. A Deployment for cluster-wide data (cluster metrics, k8s events).
#
# It should be run on the master node.
#
set -e

echo "Starting OpenTelemetry Collectors installation..."

# 1. Add the OpenTelemetry Helm repository
echo "Step 1: Adding OpenTelemetry Helm repository..."
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts

# 2. Install the DaemonSet collector for node-level metrics and logs
echo "Step 2: Installing DaemonSet collector..."
helm upgrade --install otel-collector-daemonset open-telemetry/opentelemetry-collector --namespace open-telemetry --create-namespace \
  --set mode=daemonset \
  --set presets.logsCollection.enabled=true \
  --set presets.kubernetesAttributes.enabled=true \
  --set presets.kubeletMetrics.enabled=true \
  --set presets.hostMetrics.enabled=true

# 3. Install the Deployment collector for cluster-level metrics
echo "Step 3: Installing Deployment collector..."
helm upgrade --install otel-collector-cluster open-telemetry/opentelemetry-collector --namespace open-telemetry \
  --set mode=deployment \
  --set presets.clusterMetrics.enabled=true \
  --set presets.kubernetesEvents.enabled=true

echo ""
echo "OpenTelemetry Collectors have been installed successfully."
echo "Next, configure them to export data to your backend (e.g., SigNoz)."