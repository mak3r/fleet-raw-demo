SHELL := /bin/bash
.PHONY: sleep destroy all step_01 step_02 step_03 step_04 kubeconfig join_fleet

K3S_CHANNEL := v1.21
FLEET_VERSION := 0.3.7
export KUBECONFIG := kubeconfig

destroy:
	-rm kubeconfig_fleet_manager kubeconfig_one kubeconfig_two kubeconfig_three kubeconfig_all configs/token-values.yaml ca.pem
	cd terraform-setup && terraform destroy -auto-approve && rm terraform.tfstate terraform.tfstate.backup

all: step_01 sleep step_02 sleep step_03 sleep step_04 

sleep:
	sleep 60

step_01:
	echo "Creating infrastructure"
	cd terraform-setup && terraform init && terraform apply -auto-approve

step_02: step_01
	#Install k3s on the individual clusters
	source get_env.sh && echo $${IP0}
	# The fleet manager cluster
	source get_env.sh && ssh -o StrictHostKeyChecking=no ubuntu@$${IP0} "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--tls-san $${IP0}' INSTALL_K3S_CHANNEL=$(K3S_CHANNEL) K3S_KUBECONFIG_MODE=644 sh -"
	source get_env.sh && scp -o StrictHostKeyChecking=no ubuntu@$${IP0}:/etc/rancher/k3s/k3s.yaml kubeconfig_fleet_manager
	source get_env.sh && sed -i '' "s/127.0.0.1/$${IP0}/g" kubeconfig_fleet_manager

step_03: step_01
	# The "edge nodes"
	# one
	source get_env.sh && ssh -o StrictHostKeyChecking=no ubuntu@$${IP1} "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--tls-san $${IP1}' INSTALL_K3S_CHANNEL=$(K3S_CHANNEL) K3S_KUBECONFIG_MODE=644 sh -"
	source get_env.sh && scp -o StrictHostKeyChecking=no ubuntu@$${IP1}:/etc/rancher/k3s/k3s.yaml kubeconfig_one
	source get_env.sh && sed -i '' "s/127.0.0.1/$${IP1}/g" kubeconfig_one
	# two
	source get_env.sh && ssh -o StrictHostKeyChecking=no ubuntu@$${IP2} "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--tls-san $${IP2}' INSTALL_K3S_CHANNEL=$(K3S_CHANNEL) K3S_KUBECONFIG_MODE=644 sh -"
	source get_env.sh && scp -o StrictHostKeyChecking=no ubuntu@$${IP2}:/etc/rancher/k3s/k3s.yaml kubeconfig_two
	source get_env.sh && sed -i '' "s/127.0.0.1/$${IP2}/g" kubeconfig_two
	# three
	source get_env.sh && ssh -o StrictHostKeyChecking=no ubuntu@$${IP3} "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--tls-san $${IP3}' INSTALL_K3S_CHANNEL=$(K3S_CHANNEL) K3S_KUBECONFIG_MODE=644 sh -"
	source get_env.sh && scp -o StrictHostKeyChecking=no ubuntu@$${IP3}:/etc/rancher/k3s/k3s.yaml kubeconfig_three
	source get_env.sh && sed -i '' "s/127.0.0.1/$${IP3}/g" kubeconfig_three

kubeconfig: step_02 step_03
	sed -i "" 's/default/fleet/g' ./kubeconfig_fleet_manager
	sed -i "" 's/default/one/g' ./kubeconfig_one
	sed -i "" 's/default/two/g' ./kubeconfig_two
	sed -i "" 's/default/three/g' ./kubeconfig_three
	KUBECONFIG=./kubeconfig_fleet_manager:./kubeconfig_one:./kubeconfig_two:./kubeconfig_three kubectl config view --flatten > ./kubeconfig_all 
	chmod 600 ./kubeconfig_all

install_fleet: 
	# First install the Fleet CustomResourcesDefintions.
	export KUBECONFIG=./kubeconfig_all; \
	kubectx fleet; \
	helm -n fleet-system install --create-namespace --wait \
	fleet-crd https://github.com/rancher/fleet/releases/download/v$(FLEET_VERSION)/fleet-crd-$(FLEET_VERSION).tgz

	#Second install the Fleet controllers.
	export KUBECONFIG=./kubeconfig_fleet_manager; \
	kubectl config view -o json --raw | jq -r '.clusters[].cluster["certificate-authority-data"]' | base64 -d > ca.pem; \
	export API_SERVER_URL=$(kubectl config view -o json --raw | jq -r '.clusters[].cluster["server"]'); \
	export API_SERVER_CA="ca.pem"; \
	helm -n fleet-system install --create-namespace --wait \
	--set apiServerURL="$(API_SERVER_URL)" \
    --set-file apiServerCA="$(API_SERVER_CA)" \
	fleet https://github.com/rancher/fleet/releases/p-download/v$(FLEET_VERSION)/fleet-$(FLEET_VERSION).tgz

	# check the logs
	export KUBECONFIG=./kubeconfig_all; \
	kubectx fleet; \
	kubectl -n fleet-system get pods -l app=fleet-controller; \
	kubectl apply -f configs/fleet-demo-src-repo.yaml; \
	kubectl apply -f configs/gb-group.yaml; \
	kubectl apply -f configs/ny-group.yaml; \
	kubectl apply -f configs/token.yaml; \

join_one:  
	export KUBECONFIG=./kubeconfig_all; \
	kubectx one; \
	helm -n fleet-system install --create-namespace --wait \
	--set-string labels.geo=NY --set-string labels.type=edge \
	--values configs/token-values.yaml \
	fleet-agent https://github.com/rancher/fleet/releases/download/v$(FLEET_VERSION)/fleet-agent-$(FLEET_VERSION).tgz

join_two:  
	export KUBECONFIG=./kubeconfig_all; \
	kubectx two; \
	helm -n fleet-system install --create-namespace --wait \
	--set-string labels.geo=GB --set-string labels.type=edge \
	--values configs/token-values.yaml \
	fleet-agent https://github.com/rancher/fleet/releases/download/v$(FLEET_VERSION)/fleet-agent-$(FLEET_VERSION).tgz

join_three:  
	export KUBECONFIG=./kubeconfig_all; \
	kubectx three; \
	helm -n fleet-system install --create-namespace --wait \
	--set-string labels.geo=NY --set-string labels.type=edge \
	--values configs/token-values.yaml \
	fleet-agent https://github.com/rancher/fleet/releases/download/v$(FLEET_VERSION)/fleet-agent-$(FLEET_VERSION).tgz