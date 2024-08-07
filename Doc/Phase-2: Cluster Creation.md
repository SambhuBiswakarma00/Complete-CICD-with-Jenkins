# Cluster creation with Kubeadm

- Install the kubeadm. You can find the installtion command in Terraform/Installs/kube_and_java_install.sh
- Once the installation is complete, we need to initialize the Control-Plane node of the cluster using "kubeadm init" command.
- To make kubectl work for your non-root user, run these commands, which are also part of the kubeadm init output:
  ```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  ```
- After initializing the cluster with "kubeadm init", you need to install network pods too for networking. You can use any pod-network that supports. One of the pod network that you can use is below.
  ```
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
  ```
- The nodes are where your workloads (containers and Pods, etc) run. To add new nodes to your cluster do the following for each machine
   - SSH to the machine
   - Become root (e.g. sudo su -)
   - Install a runtime if needed
   - Run the join command that was output by kubeadm init.
 
  You can check if the nodes have joined or not using the following kubectl command
  ```
  kubectl get nodes
  ```
  and this should output the list of the node that have joined the cluster.

  Note: you will be able to get nodes from master nodes, but if you run "get nodes" from slave nodes it will give an error as we need to configure the slave nodes to access the api server with proper credentials.
  so copy the config file in master nodes to the slave node and set the KUBECONFIG env variable to the path/to/configfile in the slave node by using command "export KUBECONFIG = path/to/config"
  now you will be able to access the api servers from slave nodes too.
  You can find the location of the config files at "```$HOME/.kube/config```"

You can also refer to this kubernetes official documentation page for steps for cluster creation with kubeadm. Link - https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

## Additional Step
After you have successfully created the cluster, Scan the cluster with kubeaudit
- download the kubeaudit executable 
- Move kubeaudit executable to /usr/local/bin
- Now scan the cluster with kubeaudit commands, for example
    ```kubeaduit all```
