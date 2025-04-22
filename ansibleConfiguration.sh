#!/bin/bash

sudo apt update

sudo apt install software-properties-common

sudo add-apt-repository --yes --update ppa:ansible/ansible

sudo apt install ansible

# Install Ansible az collection for interacting with Azure. (optional)
ansible-galaxy collection install azure.azcollection --force 

# Install Ansible modules for Azure (optional)
# sudo pip3 install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt

