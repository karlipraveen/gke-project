# Microservices with DB on Development Setup (GKE)

## Overview

This project provisions a **production-ready Google Kubernetes Engine (GKE)** infrastructure using **Terraform** for deploying microservices with a database in a development environment.

The infrastructure follows Google Cloud best practices and includes networking, IAM, security, and Kubernetes resources required to host containerized applications.

---

# Architecture

The Terraform project creates the following resources:

- Private GKE Cluster
- Custom VPC
- Public & Private Subnets
- Cloud Router
- Cloud NAT
- Managed Node Pool
- Service Account
- IAM Roles
- Firewall Rules
- Resource Labels
- Outputs

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

# Author

DevOps / Cloud Engineering

Infrastructure as Code using Terraform on Google Cloud Platform.
