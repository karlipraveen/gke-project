#!/bin/bash

set -euo pipefail

# ============================================================
# Jenkins CI/CD Server - GCP
#
# OS:
#   Ubuntu 22.04 / Ubuntu 24.04
#
# Installed:
#   Jenkins LTS
#   OpenJDK 21
#   Git
#   Docker
#   Docker Compose
#   AWS CLI v2
#   Google Cloud CLI
#   GKE gcloud authentication plugin
#   Python 3
#   Ansible
#   Boto3
#   Terraform
#   kubectl
#   eksctl
#   Rancher CLI
#
# ============================================================

echo "============================================================"
echo " Starting Jenkins CI/CD Server Installation"
echo "============================================================"


# ------------------------------------------------------------
# 0. Root check
# ------------------------------------------------------------

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Please run this script with sudo or as root."
    exit 1
fi


# ------------------------------------------------------------
# 1. Detect operating system
# ------------------------------------------------------------

echo ""
echo "[1/20] Detecting operating system..."

if [ ! -f /etc/os-release ]; then
    echo "ERROR: Cannot determine operating system."
    exit 1
fi

source /etc/os-release

echo "OS: ${PRETTY_NAME}"

if [ "${ID}" != "ubuntu" ]; then
    echo "ERROR: This script is intended for Ubuntu."
    echo "Detected: ${ID}"
    exit 1
fi


# ------------------------------------------------------------
# 2. Set hostname
# ------------------------------------------------------------

echo ""
echo "[2/20] Setting hostname..."

hostnamectl set-hostname jenkins-server


# ------------------------------------------------------------
# 3. Update operating system
# ------------------------------------------------------------

echo ""
echo "[3/20] Updating operating system..."

apt-get update -y
apt-get upgrade -y


# ------------------------------------------------------------
# 4. Install base packages
# ------------------------------------------------------------

echo ""
echo "[4/20] Installing base packages..."

apt-get install -y \
    ca-certificates \
    curl \
    wget \
    unzip \
    tar \
    gzip \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    fontconfig \
    git \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    jq


# ------------------------------------------------------------
# 5. Install Java 21
# ------------------------------------------------------------

echo ""
echo "[5/20] Installing OpenJDK 21..."

apt-get install -y openjdk-21-jre

echo ""
echo "Java version:"
java -version


# ------------------------------------------------------------
# 6. Install Docker
# ------------------------------------------------------------

echo ""
echo "[6/20] Installing Docker..."

apt-get install -y docker.io

systemctl enable docker
systemctl start docker

echo ""
echo "Docker version:"
docker --version


# ------------------------------------------------------------
# 7. Install Docker Compose
# ------------------------------------------------------------

echo ""
echo "[7/20] Installing Docker Compose..."

apt-get install -y docker-compose-plugin

echo ""
echo "Docker Compose version:"
docker compose version


# ------------------------------------------------------------
# 8. Install Jenkins repository
# ------------------------------------------------------------

echo ""
echo "[8/20] Configuring Jenkins LTS repository..."

# Remove old Jenkins repository/key
rm -f /etc/apt/sources.list.d/jenkins.list
rm -f /etc/apt/keyrings/jenkins-keyring.asc
rm -f /usr/share/keyrings/jenkins-keyring.asc

install -d -m 0755 /etc/apt/keyrings

# Current Jenkins signing key
wget -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

chmod 0644 /etc/apt/keyrings/jenkins-keyring.asc

cat > /etc/apt/sources.list.d/jenkins.list <<'EOF'
deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/
EOF

apt-get update -y


# ------------------------------------------------------------
# 9. Install Jenkins
# ------------------------------------------------------------

echo ""
echo "[9/20] Installing Jenkins..."

apt-get install -y jenkins

systemctl daemon-reload
systemctl enable jenkins


# ------------------------------------------------------------
# 10. Configure Jenkins user and Docker
# ------------------------------------------------------------

echo ""
echo "[10/20] Configuring Jenkins user..."

# Give Jenkins a normal shell
usermod -s /bin/bash jenkins

# Give Jenkins Docker access
usermod -aG docker jenkins

systemctl restart docker
systemctl restart jenkins


# ------------------------------------------------------------
# 11. Install AWS CLI v2
# ------------------------------------------------------------

echo ""
echo "[11/20] Installing AWS CLI v2..."

cd /tmp

rm -rf aws awscliv2.zip

curl -fsSL \
    "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o awscliv2.zip

unzip -q awscliv2.zip

if [ -x /usr/local/bin/aws ]; then
    ./aws/install --update
else
    ./aws/install
fi

rm -rf aws awscliv2.zip

echo ""
echo "AWS CLI:"
aws --version


# ------------------------------------------------------------
# 12. Install Google Cloud CLI
# ------------------------------------------------------------

echo ""
echo "[12/20] Installing Google Cloud CLI..."

# Remove old/duplicate Google Cloud repository configuration
rm -f /etc/apt/sources.list.d/google-cloud-sdk.list
rm -f /etc/apt/sources.list.d/google-cloud.list

# Google Cloud repository key
curl -fsSL \
    https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --dearmor \
    -o /usr/share/keyrings/cloud.google.gpg

chmod 0644 /usr/share/keyrings/cloud.google.gpg

# Google Cloud CLI repository
cat > /etc/apt/sources.list.d/google-cloud-sdk.list <<'EOF'
deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main
EOF

apt-get update -y

# Install Google Cloud CLI
apt-get install -y google-cloud-cli

echo ""
echo "Google Cloud CLI:"
gcloud version


# ------------------------------------------------------------
# 13. Install GKE authentication plugin
# ------------------------------------------------------------

echo ""
echo "[13/20] Installing GKE authentication plugin..."

apt-get install -y google-cloud-cli-gke-gcloud-auth-plugin

echo ""
echo "GKE authentication plugin:"
gke-gcloud-auth-plugin --version


# ------------------------------------------------------------
# 14. Configure GKE authentication for kubectl
# ------------------------------------------------------------

echo ""
echo "[14/20] Configuring GKE authentication..."

# Enable the GKE authentication plugin for Kubernetes clients.
#
# This environment variable is required/useful for kubectl
# and other Kubernetes clients that access GKE.

cat > /etc/profile.d/gke-gcloud-auth-plugin.sh <<'EOF'
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
EOF

chmod 0644 /etc/profile.d/gke-gcloud-auth-plugin.sh

# Make it available for Jenkins jobs as well
cat > /etc/default/jenkins-gke <<'EOF'
USE_GKE_GCLOUD_AUTH_PLUGIN=True
EOF

chmod 0644 /etc/default/jenkins-gke

# Add environment variable to Jenkins systemd service
mkdir -p /etc/systemd/system/jenkins.service.d

cat > /etc/systemd/system/jenkins.service.d/gke.conf <<'EOF'
[Service]
Environment="USE_GKE_GCLOUD_AUTH_PLUGIN=True"
EOF


# ------------------------------------------------------------
# 15. Install Python / Ansible / Boto3
# ------------------------------------------------------------

echo ""
echo "[15/20] Installing Python, Ansible and Boto3..."

python3 -m venv /opt/jenkins-python

/opt/jenkins-python/bin/pip install --upgrade pip

/opt/jenkins-python/bin/pip install \
    ansible \
    boto3

# Make Ansible available globally
ln -sf /opt/jenkins-python/bin/ansible \
    /usr/local/bin/ansible

ln -sf /opt/jenkins-python/bin/ansible-playbook \
    /usr/local/bin/ansible-playbook

echo ""
echo "Python:"
python3 --version

echo ""
echo "Ansible:"
ansible --version | head -n 1

echo ""
echo "Boto3:"
/opt/jenkins-python/bin/python \
    -c "import boto3; print(boto3.__version__)"


# ------------------------------------------------------------
# 16. Install Terraform
# ------------------------------------------------------------

echo ""
echo "[16/20] Installing Terraform..."

install -d -m 0755 /usr/share/keyrings

curl -fsSL \
    https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor \
    -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

chmod 0644 /usr/share/keyrings/hashicorp-archive-keyring.gpg

cat > /etc/apt/sources.list.d/hashicorp.list <<EOF
deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${VERSION_CODENAME} main
EOF

apt-get update -y

apt-get install -y terraform

echo ""
echo "Terraform:"
terraform version


# ------------------------------------------------------------
# 17. Install kubectl
# ------------------------------------------------------------

echo ""
echo "[17/20] Installing kubectl..."

cd /tmp

rm -f kubectl kubectl.sha256

# Get current stable Kubernetes version
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

echo "Installing kubectl version: ${KUBECTL_VERSION}"

curl -LO \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

curl -LO \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"

echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

install -o root -g root -m 0755 \
    kubectl \
    /usr/local/bin/kubectl

rm -f kubectl kubectl.sha256

echo ""
echo "kubectl:"
kubectl version --client


# ------------------------------------------------------------
# 18. Install eksctl
# ------------------------------------------------------------

echo ""
echo "[18/20] Installing eksctl..."

cd /tmp

rm -f eksctl.tar.gz
rm -f /tmp/eksctl

ARCH=$(uname -m)

case "${ARCH}" in
    x86_64)
        EKSCTL_ARCH="amd64"
        ;;
    aarch64|arm64)
        EKSCTL_ARCH="arm64"
        ;;
    *)
        echo "ERROR: Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

echo "System architecture: ${ARCH}"
echo "eksctl architecture: ${EKSCTL_ARCH}"

curl --silent --location \
    "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_${EKSCTL_ARCH}.tar.gz" \
    -o eksctl.tar.gz

tar -xzf eksctl.tar.gz -C /tmp

install -o root -g root -m 0755 \
    /tmp/eksctl \
    /usr/local/bin/eksctl

rm -f /tmp/eksctl.tar.gz
rm -f /tmp/eksctl

echo ""
echo "eksctl:"
eksctl version


# ------------------------------------------------------------
# 19. Install Rancher CLI
# ------------------------------------------------------------

echo ""
echo "[19/20] Installing Rancher CLI..."

cd /tmp

rm -rf rancher-cli.tar.gz rancher-cli

mkdir -p /tmp/rancher-cli

RANCHER_CLI_VERSION=$(
    curl -fsSL \
    https://api.github.com/repos/rancher/cli/releases/latest \
    | jq -r '.tag_name'
)

if [ -z "${RANCHER_CLI_VERSION}" ] || [ "${RANCHER_CLI_VERSION}" = "null" ]; then
    echo "ERROR: Could not determine latest Rancher CLI version."
    exit 1
fi

echo "Installing Rancher CLI version: ${RANCHER_CLI_VERSION}"

RANCHER_VERSION_NO_V="${RANCHER_CLI_VERSION#v}"

curl -fsSL \
    "https://github.com/rancher/cli/releases/download/${RANCHER_CLI_VERSION}/rancher-linux-amd64-${RANCHER_VERSION_NO_V}.tar.gz" \
    -o rancher-cli.tar.gz

tar -xzf rancher-cli.tar.gz -C /tmp/rancher-cli

RANCHER_BINARY=$(find /tmp/rancher-cli -type f -name rancher | head -n 1)

if [ -z "${RANCHER_BINARY}" ]; then
    echo "ERROR: Rancher CLI binary was not found."
    exit 1
fi

install -o root -g root -m 0755 \
    "${RANCHER_BINARY}" \
    /usr/local/bin/rancher

rm -rf /tmp/rancher-cli
rm -f /tmp/rancher-cli.tar.gz

echo ""
echo "Rancher CLI:"
rancher --version


# ------------------------------------------------------------
# 20. Final configuration and verification
# ------------------------------------------------------------

echo ""
echo "[20/20] Final configuration and verification..."

systemctl daemon-reload

systemctl enable docker
systemctl enable jenkins

systemctl restart docker
systemctl restart jenkins


# ============================================================
# Verification
# ============================================================

echo ""
echo "============================================================"
echo " Java"
echo "============================================================"
java -version


echo ""
echo "============================================================"
echo " Git"
echo "============================================================"
git --version


echo ""
echo "============================================================"
echo " Docker"
echo "============================================================"
docker --version


echo ""
echo "============================================================"
echo " Docker Compose"
echo "============================================================"
docker compose version


echo ""
echo "============================================================"
echo " AWS CLI"
echo "============================================================"
aws --version


echo ""
echo "============================================================"
echo " Google Cloud CLI"
echo "============================================================"
gcloud version


echo ""
echo "============================================================"
echo " GKE Authentication Plugin"
echo "============================================================"
gke-gcloud-auth-plugin --version


echo ""
echo "============================================================"
echo " Python"
echo "============================================================"
python3 --version


echo ""
echo "============================================================"
echo " Ansible"
echo "============================================================"
ansible --version | head -n 1


echo ""
echo "============================================================"
echo " Terraform"
echo "============================================================"
terraform version


echo ""
echo "============================================================"
echo " kubectl"
echo "============================================================"
kubectl version --client


echo ""
echo "============================================================"
echo " eksctl"
echo "============================================================"
eksctl version


echo ""
echo "============================================================"
echo " Rancher CLI"
echo "============================================================"
rancher --version


# ============================================================
# Test tools as Jenkins user
# ============================================================

echo ""
echo "============================================================"
echo " Testing tools as Jenkins user"
echo "============================================================"

sudo -iu jenkins bash <<'JENKINS_TEST'

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

echo ""
echo "Jenkins user:"
whoami

echo ""
echo "Jenkins shell:"
echo "$SHELL"

echo ""
echo "Google Cloud CLI:"
gcloud version

echo ""
echo "GKE authentication plugin:"
gke-gcloud-auth-plugin --version

echo ""
echo "kubectl:"
kubectl version --client

echo ""
echo "Docker:"
docker --version

echo ""
echo "Docker Compose:"
docker compose version

echo ""
echo "Terraform:"
terraform version

echo ""
echo "Ansible:"
ansible --version | head -n 1

echo ""
echo "AWS CLI:"
aws --version

echo ""
echo "eksctl:"
eksctl version

echo ""
echo "Rancher:"
rancher --version

echo ""
echo "Docker access:"
docker ps

JENKINS_TEST


# ============================================================
# Jenkins initial password
# ============================================================

echo ""
echo "============================================================"
echo " Jenkins Initial Admin Password"
echo "============================================================"

if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    cat /var/lib/jenkins/secrets/initialAdminPassword
else
    echo "Password file is not available yet."
    echo ""
    echo "Run:"
    echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
fi


# ============================================================
# Jenkins URL
# ============================================================

echo ""
echo "============================================================"
echo " Jenkins URL"
echo "============================================================"

SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "http://${SERVER_IP}:8080"


# ============================================================
# Completion
# ============================================================

echo ""
echo "============================================================"
echo " Jenkins CI/CD Installation Completed"
echo "============================================================"

echo ""
echo "Installed:"
echo "  Jenkins"
echo "  OpenJDK 21"
echo "  Git"
echo "  Docker"
echo "  Docker Compose"
echo "  AWS CLI v2"
echo "  Google Cloud CLI"
echo "  GKE Authentication Plugin"
echo "  Python 3"
echo "  Ansible"
echo "  Boto3"
echo "  Terraform"
echo "  kubectl"
echo "  eksctl"
echo "  Rancher CLI"

echo ""
echo "GKE commands can now use:"
echo "  gcloud container clusters get-credentials"
echo "  kubectl get pods"
echo "  kubectl apply -f deployment.yaml"

echo ""
echo "IMPORTANT:"
echo "1. Allow TCP 8080 in the GCP VPC firewall."
echo "2. Open http://${SERVER_IP}:8080."
echo "3. Use the Jenkins initial admin password above."
echo "4. Jenkins has Docker access."
echo "5. GKE authentication plugin is installed."
echo "6. Jenkins is configured to use the GKE authentication plugin."
echo ""