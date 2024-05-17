sudo apt update -y
# sudo apt-get install openjdk-11-jdk -y
sudo apt install docker.io -y

sudo systemctl start docker
sudo systemctl enable docker

# installing minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb

# sudo usermod -aG docker $USER && newgrp docker
sudo chmod 777 /var/run/docker.sock
minikube start


# installing kubectl as it is not installed automatically with minikube
sudo snap install kubectl --classic 

# minikube addons enable ingress