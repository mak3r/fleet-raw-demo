#!/bin/bash

kubectx fleet

# create a token
kubectl apply -f configs/token.yaml

# dump the required data into token values for downstream cluster joins
# NOTE: this will overwrite an existing token-values.yaml file
kubectl -n fleet-local get secret demo-token -o 'jsonpath={.data.values}' | base64 --decode > configs/token-values.yaml