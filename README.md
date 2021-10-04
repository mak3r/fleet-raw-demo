# How to demo Rancher fleet management without Rancher

## Setup

### Infrastructure

1. Create 4 VMs
1. Setup a load balancer for the rancher demo app on 3 of the vms

### Fleet Management Cluster

1. Install k3s
1. Install fleet manager
1. Create secret for use by downstream agents

### Fleet of Clusters

1. Install k3s on the remaining 3 vms
1. Connect clusters back to fleet manager

### Demo Process

1. Create GitRepo which targets all clusters

    ```
    <yaml for GitRepo here>
    ```

1. Create ClusterGroups for each geo

    ```
    <yaml for ClusterGroups here>
    ```


1. Describe each of the resources just created

    ```
    kubectl describe ...
    ```

1. Join and label downstream clusters with fleet manager

    ```
    <yaml for token-values here>
    ```
    * 2x - `geo=US`
    * 1x - `geo=GB`

1. Visit the url of each application
1. Make a change to the source code and commit it to the git repo
1. Watch the url of each application for changes