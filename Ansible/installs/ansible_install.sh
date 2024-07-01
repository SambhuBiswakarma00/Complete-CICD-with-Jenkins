#!/bin/bash

# Update the package list
sudo apt update

# Install software-properties-common to manage PPAs
sudo apt install software-properties-common -y

# Add the Ansible PPA
sudo add-apt-repository --yes --update ppa:ansible/ansible

# Install Ansible
sudo apt install ansible -y
