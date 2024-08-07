# Manifest Files creation for our deployment in kubernetes

Creating and deploying resources in a Kubernetes cluster involves writing YAML files for each resource, such as Deployment, Service, ServiceAccount, Role, and 
RoleBinding. Below are the detailed steps to achieve this:

Create YAML Files:
- Create deployment.yaml for the Deployment: This file describes the pods and containers to be deployed..
- Create service.yaml for the Service: This file defines how to expose your deployment as a network service..
- Create serviceaccount.yaml for the ServiceAccount: This file creates a ServiceAccount for the deployment to use..
- Create role.yaml for the Role:  Create Role YAML (role.yaml).
- Create rolebinding.yaml for the RoleBinding: This file binds the Role to the ServiceAccount..
  
Apply YAML Files:
- Use kubectl apply -f <filename> to apply each file to the cluster.
