#!/bin/bash
#
# This script installs and configures the vault-autounseal helper.
# It securely stores the unseal key and root token in Kubernetes secrets
# and deploys the autounseal controller using Helm.
#
# It should be run on the master node after Vault has been initialized.
#
set -e

echo "Starting Vault Auto-Unseal configuration..."

# 1. Prompt for the unseal key and root token
read -sp 'Enter your Vault Unseal Key: ' VAULT_UNSEAL_KEY
echo
read -sp 'Enter your Vault Root Token: ' VAULT_ROOT_TOKEN
echo

if [ -z "$VAULT_UNSEAL_KEY" ] || [ -z "$VAULT_ROOT_TOKEN" ]; then
    echo "Error: Both the unseal key and root token must be provided."
    exit 1
fi

# 2. Create Kubernetes secrets to store the keys
echo "Step 1: Creating Kubernetes secrets for Vault keys..."
kubectl -n vault create secret generic vault-keys --from-literal=key1="$VAULT_UNSEAL_KEY" --dry-run=client -o yaml | kubectl apply -f -
kubectl -n vault create secret generic vault-root-token --from-literal=token="$VAULT_ROOT_TOKEN" --dry-run=client -o yaml | kubectl apply -f -

# 3. Add the vault-autounseal Helm repository
echo "Step 2: Adding vault-autounseal Helm repository..."
helm repo add vault-autounseal https://pytoshka.github.io/vault-autounseal

# 4. Install the vault-autounseal Helm chart
echo "Step 3: Installing the vault-autounseal chart..."
helm upgrade --install vault-autounseal vault-autounseal/vault-autounseal -n vault \
  --set settings.vault_url=http://vault-ui.vault.svc.cluster.local:8200 \
  --set settings.vault_secret_shares=1 \
  --set settings.vault_secret_threshold=1 \
  --set settings.vault_root_token_secret=vault-root-token \
  --set settings.vault_keys_secret=vault-keys

echo ""
echo "Vault Auto-Unseal has been configured successfully."
echo "If the Vault pod restarts, it will now be unsealed automatically."

