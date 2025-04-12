#!/bin/bash

# Удаление пользователя и Namespace связанного с ним.

# Define variables
NAMESPACE=${1:-user1}
USER_NAME=${1:-user1}
CONTEXT_NAME="${USER_NAME}-context"
KUBECONFIG_FILE="${USER_NAME}-kubeconfig"

# Delete the RoleBinding
kubectl delete rolebinding $USER_NAME-rolebinding -n $NAMESPACE
if [ $? -eq 0 ]; then
  echo "RoleBinding $USER_NAME-rolebinding deleted from namespace $NAMESPACE."
else
  echo "Failed to delete RoleBinding $USER_NAME-rolebinding."
fi

# Delete the Role
kubectl delete role $USER_NAME-role -n $NAMESPACE
if [ $? -eq 0 ]; then
  echo "Role $USER-role deleted from namespace $NAMESPACE."
else
  echo "Failed to delete Role $USER_NAME-role."
fi

# Delete the Namespace
kubectl delete namespace $NAMESPACE
if [ $? -eq 0 ]; then
  echo "Namespace $NAMESPACE deleted."
else
  echo "Failed to delete namespace $NAMESPACE."
fi

# Remove user credentials from kubeconfig
kubectl config delete-user $USER_NAME
if [ $? -eq 0 ]; then
  echo "User $USER_NAME removed from kubeconfig."
else
  echo "Failed to remove user $USER_NAME from kubeconfig."
fi

# Remove user context from kubeconfig
kubectl config delete-context $CONTEXT_NAME
if [ $? -eq 0 ]; then
  echo "Context $CONTEXT_NAME removed from kubeconfig."
else
  echo "Failed to remove context $CONTEXT_NAME from kubeconfig."
fi

# Delete the kubeconfig file if it exists
if [ -f $KUBECONFIG_FILE ]; then
  rm -f $KUBECONFIG_FILE
  echo "Kubeconfig file $KUBECONFIG_FILE deleted."
else
  echo "Kubeconfig file $KUBECONFIG_FILE not found."
fi

echo "Script completed. User $USER_NAME and namespace $NAMESPACE have been removed."
