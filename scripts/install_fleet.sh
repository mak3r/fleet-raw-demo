#!/bin/bash

FLEET_VERSION="0.3.7"

# First install the Fleet CustomResourcesDefintions.
export KUBECONFIG=./kubeconfig_all
kubectx fleet
helm -n fleet-system install --create-namespace --wait \
fleet-crd https://github.com/rancher/fleet/releases/download/v${FLEET_VERSION}/fleet-crd-${FLEET_VERSION}.tgz

#Second install the Fleet controllers.
chmod 600 ./kubeconfig_fleet_manager
export KUBECONFIG=./kubeconfig_fleet_manager
kubectl config view -o json --raw | jq -r '.clusters[].cluster["certificate-authority-data"]' | base64 -d > ca.pem
export API_SERVER_URL=$(kubectl config view -o json --raw | jq -r '.clusters[].cluster["server"]')
export API_SERVER_CA="ca.pem"
helm -n fleet-system install --create-namespace --wait \
--set apiServerURL="${API_SERVER_URL}" \
--set-file apiServerCA="${API_SERVER_CA}" \
fleet https://github.com/rancher/fleet/releases/download/v${FLEET_VERSION}/fleet-${FLEET_VERSION}.tgz

# check the logs
export KUBECONFIG=./kubeconfig_all
kubectx fleet
kubectl -n fleet-system get pods -l app=fleet-controller
kubectl apply -f configs/fleet-demo-src-repo.yaml
kubectl apply -f configs/gb-group.yaml
kubectl apply -f configs/ny-group.yaml
kubectl apply -f configs/token.yaml