#!/bin/bash

export KUBECONFIG=./kubeconfig_all
kubectx fleet
kubectl apply -f configs/fleet-demo-src-repo.yaml
kubectl apply -f configs/gb-group.yaml
kubectl apply -f configs/ny-group.yaml