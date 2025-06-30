#!/bin/bash
#
# This script upgrades the Vault Helm release to add TLS to its Ingress,
# using the 'vault-issuer' we previously configured.
#
# It should be run on the master node after the Vault issuer is ready.
#
set -e

# --- Configuration ---
VAULT_HOSTNAME="vault.svhome.net"
# ---

echo "Upgrading Vault to enable TLS on the Ingress..."

# Upgrade the Vault Helm release with additional TLS settings
helm upgrade --install vault hashicorp/vault -n vault \
  --reuse-values \
  --set "server.ingress.annotations.[\"cert-manager\.io/cluster-issuer\"]=vault-issuer" \
  --set "server.ingress.tls[0].secretName=vault-tls" \
  --set "server.ingress.tls[0].hosts[0]=$VAULT_HOSTNAME"

echo ""
echo "Vault upgrade complete."
echo "The Vault UI will now be available at https://$VAULT_HOSTNAME"
echo "It may take a minute for the certificate to be issued and the Ingress to update."