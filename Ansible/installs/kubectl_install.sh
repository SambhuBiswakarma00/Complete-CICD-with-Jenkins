#!/bin/bash

# install kubectl on jenkins server as we will need to execute the kubectl command to deploy our application on k8 cluster from jenkins server.
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-05-12/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --short --client