#!/bin/bash

kestra_version=${kestra_version}

# Set environment
sudo echo PATH=$PATH:/home/${username}/.local/bin >> /etc/profile

# Add Java and Docker’s GPG key
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Java repo
echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" |sudo tee /etc/apt/sources.list.d/adoptium.list
# Add Docker repo
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package index
sudo apt update && sudo apt upgrade -y

# Install packages to allow apt to use a repository over HTTPS
sudo apt install -y apt-transport-https ca-certificates \
    gnupg lsb-release python3-pip \
    temurin-21-jdk \
    docker-ce docker-ce-cli containerd.io

# Install Aiven client
pip3 install aiven-client

# Add the current user to the docker group to run docker commands without sudo
sudo usermod -aG docker ${username}

# Enable Docker service to start on boot
sudo systemctl enable docker

# Start Docker service
sudo systemctl start docker

# reload user permissions
newgrp docker

# install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create /app and /app/ssl directories, updating permissions
mkdir -p /app/ssl && chown ${username}:docker -R /app 

# print some success message
echo "SUCCESS!! @ $(date)" >> /app/bootstrap.log

exit 0