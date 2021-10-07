#!/bin/bash

export KUBECONFIG=./kubeconfig_all
kubectx fleet

# create a token
kubectl apply -f configs/token.yaml

# Give k8s a chance to actually setup the token resource
sleep 2
# dump the required data into token values for downstream cluster joins
# NOTE: this will overwrite an existing token-values.yaml file
kubectl -n fleet-local get secret demo-token -o 'jsonpath={.data.values}' | base64 --decode > configs/token-values.yaml