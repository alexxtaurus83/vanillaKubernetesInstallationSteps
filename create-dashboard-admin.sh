#!/bin/bash
#
# This script creates a ServiceAccount with cluster-admin privileges
# for the Kubernetes Dashboard and retrieves its login token.
#
# It should be run on the master node.
#
set -e

DASHBOARD_NS="kubernetes-dashboard"
SA_NAME="admin-user"
SECRET_NAME="${SA_NAME}-token"

echo "Starting Dashboard admin user creation..."

# 1. Create ServiceAccount
echo "Step 1: Creating ServiceAccount '${SA_NAME}' in namespace '${DASHBOARD_NS}'..."
kubectl create serviceaccount -n ${DASHBOARD_NS} ${SA_NAME}

# 2. Create ClusterRoleBinding
echo "Step 2: Creating ClusterRoleBinding for '${SA_NAME}'..."
kubectl create clusterrolebinding -n ${DASHBOARD_NS} ${SA_NAME} --clusterrole=cluster-admin --serviceaccount=${DASHBOARD_NS}:${SA_NAME}

# 3. Create the token Secret for the ServiceAccount
echo "Step 3: Creating token Secret for '${SA_NAME}'..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  namespace: ${DASHBOARD_NS}
  name: ${SECRET_NAME}
  annotations:
    kubernetes.io/service-account.name: ${SA_NAME}
type: kubernetes.io/service-account-token
EOF

# 4. Retrieve and decode the token
echo "Step 4: Retrieving login token..."
TOKEN=$(kubectl -n ${DASHBOARD_NS} get secret ${SECRET_NAME} -o jsonpath='{.data.token}' | base64 --decode)

echo ""
echo "----------------------------------------------------------------"
echo "Admin user '${SA_NAME}' created."
echo "Use the following token to log in to the Kubernetes Dashboard:"
echo "----------------------------------------------------------------"
echo ""
echo $TOKEN
echo ""
echo "----------------------------------------------------------------"