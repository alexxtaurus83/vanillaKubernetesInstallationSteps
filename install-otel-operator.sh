#!/bin/bash
#
# This script installs the OpenTelemetry Operator for auto-instrumentation.
# It configures the operator's webhook to be secured by cert-manager
# using the 'vault-issuer'.
#
# It should be run on the master node.
#
set -e

echo "Starting OpenTelemetry Operator installation..."

# 1. Add the OpenTelemetry Helm repository if not already added
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts

# 2. Install the OpenTelemetry Operator
echo "Step 2: Installing the OpenTelemetry Operator..."
helm upgrade --install opentelemetry-operator open-telemetry/opentelemetry-operator --namespace open-telemetry-operator-system --create-namespace \
  --set admissionWebhooks.certManager.enabled=true \
  --set admissionWebhooks.certManager.issuerRef.name=vault-issuer \
  --set admissionWebhooks.certManager.issuerRef.kind=ClusterIssuer

echo ""
echo "OpenTelemetry Operator installed successfully."
echo "You can now auto-instrument applications by adding annotations to your deployments."