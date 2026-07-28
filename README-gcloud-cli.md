````markdown
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
````
