#! /bin/bash
#######################################################################################################################################
# Program .....: add-docker-gpg.sh
# Version .....: 1.0
# Description .: Add GPG keys for Docker and Kubernetes
# Created .....: 07/Feb/2023
# Updated .....: 
#######################################################################################################################################

clear

# add-apt-repository and keys for Docker/Kubernetes
rm -f /etc/apt/trusted.gpg.d/docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
yes|add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

rm -f /etc/apt/sources.list.d/kubernetes.list
rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

