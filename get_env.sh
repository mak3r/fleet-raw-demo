#!/usr/bin/env bash

$(terraform output -state=terraform-setup/terraform.tfstate -json arm_node_ips | jq -r 'keys[] as $k | "export IP\($k)=\(.[$k])"')
