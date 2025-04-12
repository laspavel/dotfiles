#!/bin/bash

# Создание отдельного пользователя и связанного с ним namespace

# Define variables
NAMESPACE=${1:-user1}
USER_NAME=${1:-user1}
CLUSTER_NAME=${2:-default}
CONTEXT_NAME="${NAMESPACE}-context"
KUBECONFIG_FILE="${NAMESPACE}-kubeconfig"
ROLE_TEMPLATE="RT01.StandartUser.yaml"
ROLE_BINDINGS="RB01.StandartUser.yaml"

export NAMESPACE
export USER_NAME

# Create the namespace
kubectl create namespace $NAMESPACE || echo "Namespace $NAMESPACE already exists."

# Create a Role with full access to the namespace
envsubst < RoleTemplates/$ROLE_TEMPLATE | kubectl apply -f -

# Create a RoleBinding to bind the Role to the user
envsubst < RoleBindings/$ROLE_BINDINGS | kubectl apply -f -

# Create a certificate for the user
openssl genrsa -out $USER_NAME.key 2048
openssl req -new -key $USER_NAME.key -out $USER_NAME.csr -subj "/CN=$USER_NAME"
openssl x509 -req -in $USER_NAME.csr -CA client-ca.crt -CAkey client-ca.key -CAcreateserial -out $USER_NAME.crt -days 365

# Add user credentials to kubeconfig
kubectl config set-credentials $USER_NAME \
  --client-certificate=$USER_NAME.crt \
  --client-key=$USER_NAME.key \
  --embed-certs=true

# Add context for the user in kubeconfig
kubectl config set-context $CONTEXT_NAME \
  --cluster=$CLUSTER_NAME \
  --namespace=$NAMESPACE \
  --user=$USER_NAME

# Set the default context for kubeconfig
kubectl config use-context $CONTEXT_NAME

# Save kubeconfig to a file
kubectl config view --minify --flatten > $KUBECONFIG_FILE

echo "Kubeconfig created and saved to $KUBECONFIG_FILE."

echo "Cleanup temporary files..."
rm $USER_NAME.key $USER_NAME.csr $USER_NAME.crt

echo "Script completed. Namespace, role, rolebinding, and kubeconfig for user $USER_NAME are ready."
