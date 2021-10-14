# How to demo Rancher fleet management without Rancher

## Terraform Prep
`make install_fleet` will do the following operations. When the make command is finished, copy the kubeconfig_all file to the users kube config directory `cp kubeconfig__all $HOME/.kube/config`

* Infrastructure
	1. Create 4 VMs
	1. Setup a load balancer for the rancher demo app on 3 of the vms

* Fleet Management Cluster

	1. Install k3s 
	1. Install fleet manager
	1. Create secret for use by downstream agents

* Fleet of Clusters

	1. Install k3s on the remaining 3 vms
	1. Connect clusters back to fleet manager

## Demo Process

1. **Explain Demo Architecture**

	`kubectx`
	
1. Explain Fleet Manager and Fleet Agent
1. **Show GitRepo yaml Configuration**

	```
	ls configs
	cat configs/fleet-demo-src-repo.yaml
	```
	
1. Show Source Code for `fleet-demo-src` and Explain
1. **Create GitRepo which targets all clusters**

    `kubectl apply -f configs/fleet-demo-src-repo.yaml`

1. **Show the git repo resource**

	```
	kubectl get crds
	kubectl get gitrepos.fleet.cattle.io -A
	kubectl describe crd -n fleet-local demo-src
	```
	
1. **Show ClusterGroup yaml Configuration**

	`cat configs/gb-group.yaml`
	
1. **Create ClusterGroups for each geo**

    ```
    kubectl apply -f configs/gb-group.yaml
    kubectl apply -f configs/ny-group.yaml
    ```
    
1. Show and Explain Makefile Downstream Cluster Commands

1. **Create the token for agents to join**

	```
	kubectl apply -f configs/token.yaml
	kubectl -n fleet-local get secret demo-token -o 'jsonpath={.data.values}' | base64 --decode > configs/token-values.yaml
	```

1. **Join downstream clusters to fleet manager**

	`make join_fleet`
	
1. Visit the url of each application
1. Make a change to the source code and commit it to the git repo
1. Watch the url of each application for changes
