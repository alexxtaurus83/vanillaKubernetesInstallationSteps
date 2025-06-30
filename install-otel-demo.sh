#!/bin/bash
#
# This script installs the OpenTelemetry Demo application.
# This is a polyglot microservices application used to generate telemetry data.
#
# It should be run on the master node.
#
set -e

# --- Configuration ---
# IMPORTANT: Change this to the desired hostname for your demo app.
# You must create a DNS A record pointing this hostname to your
# NGINX Ingress Controller's external IP address.
DEMO_HOSTNAME="otel-demo.svhome.net"
# ---

echo "Starting OpenTelemetry Demo installation for host: $DEMO_HOSTNAME"

# 1. Add the OpenTelemetry Helm repository if not already added
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts

# 2. Install the OpenTelemetry Demo chart
echo "Step 2: Installing the OpenTelemetry Demo chart (this can take several minutes)..."
helm upgrade --install my-otel-demo open-telemetry/opentelemetry-demo --namespace opentelemetry-demo --create-namespace \
  --set components.frontendProxy.ingress.enabled=true \
  --set components.frontendProxy.ingress.ingressClassName=nginx \
  --set components.frontendProxy.ingress.hosts[0].host=$DEMO_HOSTNAME \
  --set components.frontendProxy.ingress.hosts[0].paths[0].path=/ \
  --set components.frontendProxy.ingress.annotations."cert-manager\.io/cluster-issuer"=vault-issuer \
  --set components.frontendProxy.ingress.tls[0].secretName=otel-demo-tls \
  --set components.frontendProxy.ingress.tls[0].hosts[0]=$DEMO_HOSTNAME \
  --set components.loadgenerator.enabled=true

echo ""
echo "OpenTelemetry Demo installation complete."
echo "The demo frontend will be available at: https://$DEMO_HOSTNAME"
echo "Data should begin appearing in your observability backend (e.g., SigNoz) shortly."