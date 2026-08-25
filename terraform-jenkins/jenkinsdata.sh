#!/bin/bash

set -euo pipefail

# ============================================================
# Jenkins Installation Script
# Ubuntu 22.04 (Jammy)
# Jenkins LTS
# Java 21
# Docker
# ============================================================

echo "=========================================="
echo " Jenkins Installation Starting"
echo "=========================================="

# ------------------------------------------------------------
# 1. Check that script is running as root
# ------------------------------------------------------------

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Please run this script as root or with sudo."
    exit 1
fi

# ------------------------------------------------------------
# 2. Set hostname
# ------------------------------------------------------------

echo "[1/10] Setting hostname..."

hostnamectl set-hostname jenkins-server

# ------------------------------------------------------------
# 3. Remove old Jenkins repository configuration
# ------------------------------------------------------------

echo "[2/10] Removing old Jenkins repository configuration..."

rm -f /etc/apt/sources.list.d/jenkins.list
rm -f /etc/apt/keyrings/jenkins-keyring.asc
rm -f /usr/share/keyrings/jenkins-keyring.asc

# ------------------------------------------------------------
# 4. Update Ubuntu packages
# ------------------------------------------------------------

echo "[3/10] Updating Ubuntu packages..."

apt-get update -y

# ------------------------------------------------------------
# 5. Install required packages
# ------------------------------------------------------------

echo "[4/10] Installing required packages..."

apt-get install -y \
    ca-certificates \
    curl \
    wget \
    fontconfig \
    openjdk-21-jre \
    git \
    docker.io

# ------------------------------------------------------------
# 6. Verify Java
# ------------------------------------------------------------

echo "[5/10] Checking Java installation..."

java -version

# ------------------------------------------------------------
# 7. Configure Docker
# ------------------------------------------------------------

echo "[6/10] Configuring Docker..."

systemctl enable docker
systemctl start docker

echo "Docker version:"
docker --version

# ------------------------------------------------------------
# 8. Add current Jenkins 2026 repository key
# ------------------------------------------------------------

echo "[7/10] Installing Jenkins repository signing key..."

install -d -m 0755 /etc/apt/keyrings

wget -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

chmod 0644 /etc/apt/keyrings/jenkins-keyring.asc

# ------------------------------------------------------------
# 9. Add Jenkins LTS repository
# ------------------------------------------------------------

echo "[8/10] Adding Jenkins LTS repository..."

cat > /etc/apt/sources.list.d/jenkins.list <<'EOF'
deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/
EOF

# Update repository information
apt-get update -y

# ------------------------------------------------------------
# 10. Install and configure Jenkins
# ------------------------------------------------------------

echo "[9/10] Installing Jenkins..."

apt-get install -y jenkins

echo "[10/10] Configuring Jenkins..."

# Enable Jenkins at boot
systemctl enable jenkins

# Add Jenkins user to Docker group
usermod -aG docker jenkins

# Reload systemd and restart Jenkins
systemctl daemon-reload
systemctl restart jenkins

# ------------------------------------------------------------
# Verify Jenkins
# ------------------------------------------------------------

echo ""
echo "=========================================="
echo " Jenkins Installation Complete"
echo "=========================================="

echo ""
echo "Jenkins service status:"
systemctl --no-pager --full status jenkins

echo ""
echo "Jenkins enabled status:"
systemctl is-enabled jenkins

echo ""
echo "Jenkins running status:"
systemctl is-active jenkins

echo ""
echo "Jenkins version:"
jenkins --version || true

echo ""
echo "Docker version:"
docker --version

echo ""
echo "Java version:"
java -version

echo ""
echo "=========================================="
echo " Jenkins Initial Admin Password"
echo "=========================================="

if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    cat /var/lib/jenkins/secrets/initialAdminPassword
else
    echo "Password file is not available yet."
    echo ""
    echo "Check with:"
    echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
fi

echo ""
echo "=========================================="
echo " Jenkins URL"
echo "=========================================="

SERVER_IP=$(hostname -I | awk '{print $1}')

echo "http://${SERVER_IP}:8080"

echo ""
echo "Installation finished successfully."
