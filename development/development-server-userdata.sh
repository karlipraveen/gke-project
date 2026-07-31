#!/bin/bash

set -e

# ------------------------------------------------------------
# Update OS
# ------------------------------------------------------------

apt-get update -y
apt-get upgrade -y


# ------------------------------------------------------------
# Set hostname
# ------------------------------------------------------------

hostnamectl set-hostname Development-Server


# ------------------------------------------------------------
# Install Docker
# ------------------------------------------------------------

apt-get install -y \
    docker.io \
    docker-compose \
    git \
    curl \
    openjdk-11-jdk


# ------------------------------------------------------------
# Enable Docker
# ------------------------------------------------------------

systemctl enable docker
systemctl start docker


# ------------------------------------------------------------
# Add devops user to Docker group
# ------------------------------------------------------------

usermod -aG docker devops


# ------------------------------------------------------------
# Install Docker Compose
# ------------------------------------------------------------

curl -L \
  "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose


# ------------------------------------------------------------
# Clone Petclinic repository
# ------------------------------------------------------------

cd /home/devops

if [ ! -d "microservices-with-db-on-dev-server" ]; then

    git clone \
      https://github.com/cmakkaya/microservices-with-db-on-dev-server.git

fi


# ------------------------------------------------------------
# Change directory
# ------------------------------------------------------------

cd /home/devops/microservices-with-db-on-dev-server


# ------------------------------------------------------------
# Create dev branch
# ------------------------------------------------------------

git checkout -b dev || git checkout dev


# ------------------------------------------------------------
# Fix ownership
# ------------------------------------------------------------

chown -R devops:devops \
  /home/devops/microservices-with-db-on-dev-server


echo "Petclinic development server setup completed."