#! /bin/bash

# set server hostname as jenkins-server
hostnamectl set-hostname jenkins-server

# update os
apt-get update -y
apt-get install -y openjdk-17-jdk
apt-get install -y git
apt-get install -y docker.io
systemctl enable docker
systemctl start docker

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

apt-get update
apt-get install -y jenkins
systemctl enable jenkins
systemctl start jenkins
