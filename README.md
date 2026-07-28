# Microservices with DB on Development Setup (GKE)

## Overview

This project provisions a **production-ready Google Kubernetes Engine (GKE)** infrastructure using **Terraform** for deploying microservices with a database in a development environment.

The infrastructure follows Google Cloud best practices and includes networking, IAM, security, and Kubernetes resources required to host containerized applications.

---

# Architecture

The Terraform project creates the following resources:

- ✅Private GKE Cluster
- ✅Custom VPC
- ✅Public & Private Subnets
- ✅Cloud Router
- ✅Cloud NAT
- ✅Managed Node Pool
- ✅Service Account
- ✅IAM Roles
- ✅Firewall Rules
- ✅Resource Labels
- ✅Outputs

---

# Project Structure

```text
terraform-gke/
│
├── provider.tf
├── versions.tf
├── variables.tf
├── terraform.tfvars
├── locals.tf
├── network.tf
├── iam.tf
├── gke.tf
├── firewall.tf
├── outputs.tf
└── README.md
```

---

# Infrastructure Components

## Networking

The project provisions:

- Custom VPC
- Public Subnet
- Private Subnet
- Cloud Router
- Cloud NAT
- Private Google Access
- Firewall Rules

---

## Kubernetes

The project creates:

- Private GKE Cluster
- Managed Node Pool
- Node Auto Repair
- Node Auto Upgrade
- Cluster Autoscaling
- Shielded GKE Nodes
- VPC Native Networking

---

## Security

The project includes:

- Dedicated Service Account
- IAM Roles
- Firewall Rules
- Private Cluster
- Cloud NAT
- Resource Labels

---

# IAM Roles Used

The following IAM roles are assigned to the GKE Node Service Account.

| IAM Role | Purpose |
|----------|---------|
| roles/logging.logWriter | Write logs to Cloud Logging |
| roles/monitoring.metricWriter | Send metrics to Cloud Monitoring |
| roles/artifactregistry.reader | Pull Docker images from Artifact Registry |
| roles/storage.objectViewer | Read objects from Cloud Storage |

---

# Optional Production IAM Roles

Depending on your workloads, additional IAM roles may be required.

| IAM Role | Purpose |
|----------|---------|
| roles/secretmanager.secretAccessor | Read secrets from Secret Manager |
| roles/cloudsql.client | Connect to Cloud SQL |
| roles/pubsub.publisher | Publish messages to Pub/Sub |
| roles/pubsub.subscriber | Subscribe to Pub/Sub topics |
| roles/container.developer | Limited GKE administration |
| roles/container.admin | Full GKE administration |

---

# Prerequisites

Before deploying the infrastructure, ensure the following:

- Google Cloud SDK installed
- Terraform >= 1.5
- kubectl installed
- Authenticated with Google Cloud


# Installing Google Cloud CLI (gcloud) on Windows

This guide explains how to install the **Google Cloud CLI (gcloud)** on a Windows desktop and configure it for managing Google Cloud resources, GKE clusters, and Terraform deployments.

---

# Prerequisites

Before installing the Google Cloud CLI, ensure you have:

- Windows 10 or Windows 11
- Google Cloud Account
- A Google Cloud Project
- Administrator access on your computer
- Internet connection

---

# Step 1: Download Google Cloud CLI

Download the installer from the official Google Cloud website.

Google Cloud CLI Installation Guide:

https://cloud.google.com/sdk/docs/install

Or download directly:

https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe

Run the installer.

During installation, enable the following options:

- Add Google Cloud CLI to PATH
- Install bundled Python (if Python is not installed)
- Launch Google Cloud CLI after installation

---

# Step 2: Verify Installation

Open **PowerShell** or **Command Prompt**.

Run:

```powershell
gcloud version
```

Example Output

```text
Google Cloud SDK 530.0.0

alpha
beta
bq
core
gcloud
gsutil
kubectl
```

---

# Step 3: Login to Google Cloud

Authenticate using your Google account.

```powershell
gcloud auth login
```

A browser window opens.

Login using your Google Cloud account.

After successful authentication, you should see:

```text
You are now logged in.
```

---

# Step 4: List Available Projects

```powershell
gcloud projects list
```

Example

```text
PROJECT_ID                 NAME

fashion-dev-project        Fashion Dev

fashion-prod-project       Fashion Production
```

---

# Step 5: Set Default Project

```powershell
gcloud config set project PROJECT_ID
```

Example

```powershell
gcloud config set project fashion-prod-project
```

Verify

```powershell
gcloud config list
```

---

# Step 6: Configure Default Region

```powershell
gcloud config set compute/region us-central1
```

Verify

```powershell
gcloud config get-value compute/region
```

Expected Output

```text
us-central1
```

---

# Step 7: Configure Default Zone

```powershell
gcloud config set compute/zone us-central1-a
```

Verify

```powershell
gcloud config get-value compute/zone
```

Expected Output

```text
us-central1-a
```

---

# Step 8: Install GKE Authentication Plugin

The authentication plugin is required for Kubernetes clusters.

Install it:

```powershell
gcloud components install gke-gcloud-auth-plugin
```

Enable the plugin permanently.

PowerShell

```powershell
setx USE_GKE_GCLOUD_AUTH_PLUGIN True
```

Restart PowerShell.

Verify

```powershell
echo $env:USE_GKE_GCLOUD_AUTH_PLUGIN
```

---

# Step 9: Install kubectl

Install Kubernetes CLI.

```powershell
gcloud components install kubectl
```

Verify

```powershell
kubectl version --client
```

Example Output

```text
Client Version: v1.33
```

---

# Step 10: Install Terraform

Download Terraform

https://developer.hashicorp.com/terraform/downloads

Verify installation

```powershell
terraform version
```

Example

```text
Terraform v1.10.x
```

---

# Step 11: Verify Authentication

```powershell
gcloud auth list
```

Example

```text
Credentialed Accounts

ACTIVE

user@gmail.com
```

---

# Step 12: List Compute Engine Instances

```powershell
gcloud compute instances list
```

Example

```text
NAME                  ZONE

jenkins-server        us-central1-a
```

---

# Step 13: SSH into Compute Engine VM

```powershell
gcloud compute ssh jenkins-server --zone us-central1-a
```

---

# Step 14: List GKE Clusters

```powershell
gcloud container clusters list
```

Example

```text
NAME

fashion-gke
```

---

# Step 15: Connect to GKE Cluster

```powershell
gcloud container clusters get-credentials fashion-gke \
--region us-central1
```

Verify

```powershell
kubectl get nodes
```

Expected Output

```text
NAME

gke-node-1

gke-node-2
```

---

# Step 16: Useful Kubernetes Commands

List namespaces

```powershell
kubectl get ns
```

List Pods

```powershell
kubectl get pods -A
```

List Services

```powershell
kubectl get svc -A
```

List Deployments

```powershell
kubectl get deployments -A
```

Describe Pod

```powershell
kubectl describe pod <pod-name>
```

View Logs

```powershell
kubectl logs <pod-name>
```

---

# Step 17: Terraform Workflow

Navigate to Terraform project

```powershell
cd C:\Users\user\Desktop\gke-project
```

Initialize Terraform

```powershell
terraform init
```

Format code

```powershell
terraform fmt
```

Validate configuration

```powershell
terraform validate
```

Generate execution plan

```powershell
terraform plan
```

Deploy infrastructure

```powershell
terraform apply
```

Destroy infrastructure

```powershell
terraform destroy
```

---

# Step 18: Frequently Used gcloud Commands

## Show SDK Version

```powershell
gcloud version
```

## List Projects

```powershell
gcloud projects list
```

## Set Project

```powershell
gcloud config set project PROJECT_ID
```

## Show Current Configuration

```powershell
gcloud config list
```

## List Compute Engine Instances

```powershell
gcloud compute instances list
```

## SSH into VM

```powershell
gcloud compute ssh INSTANCE_NAME --zone us-central1-a
```

## List GKE Clusters

```powershell
gcloud container clusters list
```

## Get GKE Credentials

```powershell
gcloud container clusters get-credentials fashion-gke --region us-central1
```

## List Service Accounts

```powershell
gcloud iam service-accounts list
```

## List Artifact Registry Repositories

```powershell
gcloud artifacts repositories list
```

## List Cloud SQL Instances

```powershell
gcloud sql instances list
```

## List Storage Buckets

```powershell
gcloud storage buckets list
```

## List Enabled APIs

```powershell
gcloud services list
```

---

# Step 19: Troubleshooting

## gcloud Command Not Found

Error

```text
'gcloud' is not recognized as an internal or external command
```

Resolution

- Restart PowerShell or Command Prompt.
- Verify the Google Cloud SDK installation directory is added to the system PATH.
- Reinstall the Google Cloud CLI if necessary.

---

## Authentication Error

```powershell
gcloud auth login
```

---

## Project Not Set

```powershell
gcloud config set project PROJECT_ID
```

---

## Kubernetes Authentication Failed

```powershell
gcloud components install gke-gcloud-auth-plugin
```

Restart PowerShell and retry:

```powershell
kubectl get nodes
```

---

# Installation Verification Checklist

| Component | Command | Expected Result |
|-----------|---------|-----------------|
| Google Cloud CLI | `gcloud version` | Displays SDK version |
| Authentication | `gcloud auth list` | Shows active account |
| Project | `gcloud config list` | Displays project, region, zone |
| Compute Engine | `gcloud compute instances list` | Lists VM instances |
| GKE | `gcloud container clusters list` | Lists Kubernetes clusters |
| kubectl | `kubectl version --client` | Displays kubectl version |
| Terraform | `terraform version` | Displays Terraform version |

---

# Next Steps

After successfully installing and configuring the Google Cloud CLI:

- Provision infrastructure using Terraform.
- Create VPCs, subnets, and firewall rules.
- Deploy GKE clusters.
- Configure Artifact Registry.
- Install Jenkins on Compute Engine.
- Deploy microservices to GKE.
- Manage applications using Argo CD.
- Monitor workloads with Cloud Monitoring and Cloud Logging.
- Secure secrets using Secret Manager.
- Configure Cloud SQL and Memorystore.
- Implement CI/CD pipelines with Cloud Build and GitHub.
  

```bash
gcloud auth login
```

Set the project:

```bash
gcloud config set project <PROJECT_ID>
```

Enable required APIs:

```bash
gcloud services enable \
container.googleapis.com \
compute.googleapis.com \
iam.googleapis.com \
artifactregistry.googleapis.com \
cloudresourcemanager.googleapis.com
```

---

# Deployment Steps

Initialize Terraform.

```bash
terraform init
```

Format Terraform code.

```bash
terraform fmt
```

Validate configuration.

```bash
terraform validate
```

Review execution plan.

```bash
terraform plan
```

Deploy infrastructure.

```bash
terraform apply
terraform apply -var="cluster_name=eks-cumhur-cluster" -auto-approve
```

---

# Verify the Cluster

Configure kubectl.

```bash
gcloud container clusters get-credentials prod-gke \
--region us-central1 \
--project my-gcp-project
```

Verify cluster nodes.

```bash
kubectl get nodes
```

Verify all workloads.

```bash
kubectl get pods -A
```

---

# Project Files

| File | Description |
|------|-------------|
| provider.tf | Google Provider configuration |
| versions.tf | Terraform and Provider versions |
| variables.tf | Input variables |
| terraform.tfvars | Variable values |
| locals.tf | Labels and reusable variables |
| network.tf | VPC, Subnets, Cloud Router, Cloud NAT |
| firewall.tf | Firewall Rules |
| iam.tf | Service Account and IAM Roles |
| gke.tf | GKE Cluster and Node Pool |
| outputs.tf | Terraform Outputs |

---

# Outputs

Terraform provides the following outputs after deployment.

- Cluster Name
- Cluster Endpoint
- VPC Name
- Subnet Name

---

# Best Practices

- Use a Private GKE Cluster.
- Enable Private Google Access.
- Use Cloud NAT for outbound internet access.
- Store Terraform state remotely in a GCS bucket.
- Enable Cloud Logging and Cloud Monitoring.
- Use Workload Identity Federation instead of broad OAuth scopes where possible.
- Store application secrets in Secret Manager.
- Enable Cluster Autoscaling and Node Auto Repair.
- Use Artifact Registry for container images.
- Protect internet-facing workloads with Cloud Armor.
- Use HTTPS Load Balancer for external traffic.

---

# Cleanup

Destroy all created resources.

```bash
terraform destroy
```

---

# Technologies Used

- Google Cloud Platform (GCP)
- Google Kubernetes Engine (GKE)
- Terraform
- Kubernetes
- Cloud NAT
- Cloud Router
- IAM
- Artifact Registry
- Cloud Logging
- Cloud Monitoring

---


# End-to-End GCP CI/CD Pipeline for Microservices on GKE

## Overview

This document explains the end-to-end Continuous Integration and Continuous Deployment (CI/CD) pipeline implemented on **Google Cloud Platform (GCP)** for deploying microservices into **Google Kubernetes Engine (GKE)**.

The pipeline follows GitOps principles using **GitHub, Jenkins, Docker, Artifact Registry, Helm, ArgoCD, and GKE**.

<img width="1619" height="972" alt="image" src="https://github.com/user-attachments/assets/a7aa32a7-347d-4a79-a6d5-04d4d1b5868a" />

---

# Architecture Overview

```text
Developer
    │
    ▼
VS Code
    │
Terraform
    │
GitHub Repository
    │
Git Push
    │
Webhook
    ▼
Jenkins CI Pipeline
    │
    ├── Checkout Source Code
    ├── Compile Application
    ├── Unit Testing
    ├── SonarQube Scan
    ├── Trivy Image Scan
    ├── Docker Build
    ├── Push Image to Artifact Registry
    └── Update Helm Chart
             │
             ▼
      GitOps Repository
             │
             ▼
          ArgoCD
             │
             ▼
Google Kubernetes Engine (GKE)
             │
     Kubernetes Resources
             │
     Deployment / Service / Ingress
             │
        Microservices Pods
             │
     Cloud SQL / Memorystore
             │
Cloud Monitoring / Grafana / Prometheus
             │
HTTPS Load Balancer
             │
Cloud Armor
             │
Cloud CDN
             │
Cloud DNS
             │
          End Users
```

---

# Technology Stack

| Category | Technology |
|----------|------------|
| Source Code | GitHub |
| IDE | VS Code |
| Infrastructure | Terraform |
| CI Tool | Jenkins |
| Build Tool | Maven / Gradle |
| Code Quality | SonarQube |
| Security Scan | Trivy |
| Containerization | Docker |
| Image Repository | Artifact Registry |
| Package Manager | Helm |
| CD Tool | ArgoCD |
| Kubernetes | Google Kubernetes Engine (GKE) |
| Database | Cloud SQL |
| Cache | Memorystore (Redis) |
| Monitoring | Prometheus |
| Dashboard | Grafana |
| Cloud Monitoring | Cloud Monitoring & Cloud Logging |
| DNS | Cloud DNS |
| Load Balancer | Global HTTPS Load Balancer |
| WAF | Cloud Armor |
| CDN | Cloud CDN |

---

# Step 1 - Infrastructure Provisioning

Infrastructure is provisioned using Terraform.

Terraform creates the following resources:

- Custom VPC
- Public Subnet
- Private Subnet
- Cloud Router
- Cloud NAT
- Firewall Rules
- Service Accounts
- IAM Roles
- Artifact Registry
- GKE Cluster
- Node Pools
- Cloud SQL
- Cloud Storage Bucket

Terraform Commands

```bash
terraform init

terraform fmt

terraform validate

terraform plan

terraform apply
```

---

# Step 2 - Application Development

Developers build microservices using Java Spring Boot or NodeJS.

Example services:

- User Service
- Order Service
- Payment Service
- Notification Service

Source code is committed to GitHub.

```bash
git add .

git commit -m "Added new feature"

git push origin main
```

---

# Step 3 - GitHub Webhook

After pushing code,

GitHub automatically triggers Jenkins using Webhooks.

```text
Developer

↓

GitHub

↓

Webhook

↓

Jenkins
```

---

# Step 4 - Jenkins Continuous Integration

Jenkins executes the CI pipeline.

Pipeline stages include:

### Checkout

Clone source code.

```bash
git clone
```

---

### Build

Compile application.

```bash
mvn clean package

or

gradle build
```

Produces:

```
application.jar
```

---

### Unit Testing

Execute JUnit or Mockito test cases.

Pipeline stops if tests fail.

---

### Code Quality Analysis

Run SonarQube scan.

Checks include:

- Bugs
- Vulnerabilities
- Code Smells
- Code Coverage

---

### Security Scan

Run image vulnerability scan using Trivy.

Example:

```bash
trivy image user-service:v1
```

---

### Docker Image Build

Create Docker image.

```bash
docker build -t user-service:v1 .
```

---

### Push Image

Push Docker image into Artifact Registry.

```bash
docker push us-central1-docker.pkg.dev/project-id/repository/user-service:v1
```

---

# Step 5 - Update Helm Charts

Jenkins updates the image tag inside:

```
values.yaml
```

Example:

```yaml
image:
  repository: us-central1-docker.pkg.dev/project-id/repository/user-service
  tag: v10
```

Commit changes.

```bash
git add .

git commit -m "Updated image"

git push
```

---

# Step 6 - Continuous Delivery Using ArgoCD

ArgoCD continuously monitors the GitOps repository.

Whenever any Kubernetes manifest changes:

- Deployment
- Service
- ConfigMap
- Secret
- Helm Chart
- values.yaml

ArgoCD automatically synchronizes changes with GKE.

```text
GitHub

↓

ArgoCD

↓

GKE
```

No manual deployment is required.

---

# Step 7 - Application Deployment

ArgoCD deploys the following Kubernetes resources:

- Namespace
- Deployment
- Service
- ConfigMap
- Secret
- Ingress
- Horizontal Pod Autoscaler
- Persistent Volume Claims

Applications start inside GKE.

---

# Step 8 - Rolling Deployment

Kubernetes performs rolling updates.

Benefits:

- Zero downtime
- Gradual rollout
- Automatic rollback (if configured)

Health checks include:

- Startup Probe
- Readiness Probe
- Liveness Probe

---

# Step 9 - Autoscaling

## Horizontal Pod Autoscaler (HPA)

Automatically increases pod count based on:

- CPU Utilization
- Memory Utilization
- Custom Metrics

Example

```
3 Pods

↓

6 Pods

↓

10 Pods
```

---

## Cluster Autoscaler

Automatically adds new worker nodes when required.

Example

```
3 Nodes

↓

6 Nodes
```

---

# Step 10 - Database

Instead of AWS RDS,

GCP uses Cloud SQL.

Supported databases:

- MySQL
- PostgreSQL
- SQL Server

Applications connect securely using:

- Private IP
- Cloud SQL Auth Proxy

---

# Step 11 - Caching

Instead of AWS ElastiCache,

GCP uses Memorystore.

Supported cache:

- Redis

Benefits:

- Faster response time
- Reduced database load
- Improved application performance

---

# Step 12 - Monitoring

Application metrics are collected using:

- Prometheus
- Grafana
- Cloud Monitoring
- Cloud Logging

Metrics include:

- CPU
- Memory
- Network
- Disk Usage
- Pod Status
- Node Health

---

# Step 13 - Alerting

Configure alerts for:

- CPU > 80%
- Memory > 85%
- Disk Usage > 90%
- Pod Restart
- CrashLoopBackOff
- Node Not Ready

Notification channels:

- Email
- Slack
- PagerDuty
- Opsgenie

---

# Step 14 - External Access

Traffic flow:

```
Internet

↓

Cloud DNS

↓

Global HTTPS Load Balancer

↓

Cloud Armor

↓

Cloud CDN

↓

Ingress

↓

Kubernetes Service

↓

Application Pods
```

---

# Step 15 - SSL Certificates

Use Google Managed SSL Certificates.

Benefits:

- Automatic certificate provisioning
- Automatic renewal
- No manual certificate management

---

# Deployment Flow

```text
Developer
     │
     ▼
VS Code
     │
Terraform
     │
GitHub
     │
Webhook
     ▼
Jenkins
     │
Checkout
     │
Compile
     │
Unit Testing
     │
SonarQube
     │
Trivy Scan
     │
Docker Build
     │
Artifact Registry
     │
Helm Update
     │
GitOps Repository
     │
ArgoCD
     │
Sync
     ▼
Google Kubernetes Engine
     │
Ingress
     │
Service
     │
Pods
     │
Cloud SQL
     │
Memorystore
     │
Cloud Monitoring
     │
Grafana
     │
Prometheus
     │
HTTPS Load Balancer
     │
Cloud Armor
     │
Cloud CDN
     │
Cloud DNS
     │
Users
```

---

# AWS to GCP Service Mapping

| AWS | GCP |
|------|-----|
| EC2 | Compute Engine |
| EKS | Google Kubernetes Engine (GKE) |
| ECR | Artifact Registry |
| S3 | Cloud Storage |
| Route 53 | Cloud DNS |
| Application Load Balancer | Global HTTPS Load Balancer |
| CloudFront | Cloud CDN |
| AWS WAF | Cloud Armor |
| IAM Roles | IAM Service Accounts & IAM Roles |
| RDS | Cloud SQL |
| ElastiCache | Memorystore (Redis) |
| CloudWatch | Cloud Monitoring & Cloud Logging |
| Auto Scaling Group | GKE Cluster Autoscaler |
| Secrets Manager | Secret Manager |

---

# Best Practices

- Use private GKE clusters.
- Use Cloud NAT for outbound internet access.
- Enable Workload Identity Federation.
- Store images in Artifact Registry.
- Enable auto-repair and auto-upgrade for node pools.
- Use GitOps with ArgoCD.
- Use Google Managed SSL Certificates.
- Enable Cloud Armor and Cloud CDN for internet-facing applications.
- Store secrets in Secret Manager.
- Enable Cloud Monitoring dashboards and alerting.

---

# Conclusion

This CI/CD pipeline provides a secure, scalable, and automated deployment platform on Google Cloud Platform. Developers only need to push code to GitHub. The remaining stages—including build, testing, security scanning, containerization, image publishing, GitOps synchronization, deployment to GKE, monitoring, and autoscaling—are fully automated, enabling reliable and zero-downtime application delivery.


# Author

DevOps / Cloud Engineering

Infrastructure as Code using Terraform on Google Cloud Platform.
