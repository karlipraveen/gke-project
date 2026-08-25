# Jenkins on Google Compute Engine

This Terraform configuration creates a Jenkins server on a Google Compute Engine VM. It uses the project’s existing default Compute Engine service account, assigns an ephemeral public IP, and opens SSH (22), HTTP (80), and Jenkins (8080) in the VPC firewall.

The configuration is the GCP equivalent of the AWS Jenkins Terraform setup. AWS IAM roles and policies are represented in GCP by service accounts and IAM roles. This version uses the existing Compute Engine default service account because restricted training projects commonly do not allow users to create service accounts or change project IAM policy.

## Prerequisites

- A Google Cloud project with billing enabled.
- The Google Cloud CLI (`gcloud`) and Terraform (version 1.5 or newer).
- A Google account with permission to create Compute Engine instances and firewall rules.
- An existing VPC and subnet, or permission to use the project `default` network.

## Authenticate and enable APIs

Authenticate with the Google account that owns or has access to the project:

```powershell
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login
gcloud auth list
gcloud config get-value project
```

Enable the APIs required by the VM, firewall, container pipeline, logging, and monitoring configuration:

```powershell
gcloud services enable compute.googleapis.com iam.googleapis.com artifactregistry.googleapis.com container.googleapis.com logging.googleapis.com monitoring.googleapis.com
```

## Configure variables

Edit [`jenkins.auto.tfvars`](jenkins.auto.tfvars) before applying. At minimum, replace `project_id` and choose a region and zone available in that project:

```hcl
project_id              = "YOUR_PROJECT_ID"
region                  = "us-west3"
zone                    = "us-west3-a"
machine_type            = "e2-standard-2"
image                   = "ubuntu-os-cloud/ubuntu-2204-lts"
network                 = "default"
subnetwork              = "default"
jenkins_server_name     = "fashion-ethical-jenkins-server"
startup_script          = "jenkinsdata.sh"
```

The VM image must be Ubuntu or another Debian-family image because [`jenkinsdata.sh`](jenkinsdata.sh) installs packages with `apt`. Unlike the AWS version, GCP does not require an EC2 `.pem` key or access-key variables. SSH access is handled by `gcloud compute ssh` and the account configured with `gcloud`.
The VM uses the existing default Compute Engine service account (`PROJECT_NUMBER-compute@developer.gserviceaccount.com`), so this configuration does not create a service account or change project IAM policy.

## Create the GCP role equivalent

In AWS, the original procedure creates `tf-jenkins-server-role` and attaches ECR, CloudFormation, and Administrator policies. In GCP, the equivalent identity is a service account attached to the Compute Engine VM.

This module uses the existing default Compute Engine service account:

```text
PROJECT_NUMBER-compute@developer.gserviceaccount.com
```

Find the project number and confirm the available service accounts:

```powershell
gcloud projects describe YOUR_PROJECT_ID --format="value(projectNumber)"
gcloud iam service-accounts list --project=YOUR_PROJECT_ID
```

The default account is attached automatically when no custom `service_account` block is specified in `compute.tf`. This avoids requiring `roles/iam.serviceAccountAdmin` and `roles/iam.serviceAccountUser`, which are unavailable to many Qwiklabs users. Do not enter your Google user email in `jenkins_service_account`; it is not a valid service-account ID and this variable is no longer used.

The default account must have enough permissions for the Jenkins pipeline. In a normal GCP project, an administrator should grant narrowly scoped roles such as:

- `roles/artifactregistry.writer` for pushing images.
- `roles/container.developer` or an appropriate GKE deployment role.
- `roles/storage.objectViewer` or another storage role required by the pipeline.
- `roles/logging.logWriter` and `roles/monitoring.metricWriter` for telemetry.

Granting project-wide `roles/editor` is broader than recommended and should only be used where the project’s policy permits it. Do not grant `roles/owner` to the VM service account.

## Provision the server

Run these commands from this directory:

```powershell
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Review the plan and enter `yes` when prompted. For an unattended deployment, use `terraform apply -auto-approve`.

Terraform prints the public IP, Jenkins URL, and service-account email when the deployment completes:

```text
Jenkins_URL = "http://PUBLIC_IP:8080"
```

Jenkins installation runs asynchronously in the VM startup script. Wait until the service is ready, then open the printed URL. The first installation can take several minutes.

The startup script installs Git, Docker, Java 21, and Jenkins LTS. It uses Unix LF line endings and the current Jenkins repository signing key. Windows CRLF line endings can cause `/bin/bash^M: bad interpreter`, so preserve LF line endings when editing [`jenkinsdata.sh`](jenkinsdata.sh).

The first deployment creates the VM and firewall rule. The Jenkins package installation continues in the VM startup script, so wait about five minutes before opening the Jenkins URL.

## Tools installed by `jenkinsdata.sh`

The [`jenkinsdata.sh`](jenkinsdata.sh) startup script runs automatically on the Compute Engine VM as root. It exits if it is not running with root privileges, and performs the following setup:

- Sets the VM hostname to `jenkins-server`.
- Removes older Jenkins repository and keyring files before configuring the current repository.
- Updates the Ubuntu package indexes.
- Installs `ca-certificates`, `curl`, and `wget` for secure downloads.
- Installs `fontconfig` and OpenJDK 21 JRE, which is required by current Jenkins LTS releases.
- Installs Git for checking out application source code.
- Installs Docker Engine and enables it to start automatically.
- Installs the Docker Compose plugin and makes the `docker compose` command available.
- Adds the Jenkins LTS Debian repository and its current signing key.
- Installs Jenkins LTS and enables the Jenkins systemd service at boot.
- Adds the `jenkins` user to the Docker group so Jenkins pipelines can run Docker commands.
- Installs AWS CLI v2 for AWS-compatible pipeline commands.
- Installs the Google Cloud CLI (`gcloud`) for GCP resource and GKE operations.
- Installs the GKE authentication plugin and configures `USE_GKE_GCLOUD_AUTH_PLUGIN=True` for shell sessions and Jenkins.
- Creates a Python virtual environment at `/opt/jenkins-python` and installs Ansible and Boto3 in it.
- Makes `ansible` and `ansible-playbook` available through `/usr/local/bin`.
- Installs Terraform from the official HashiCorp APT repository.
- Installs the latest stable `kubectl` binary after verifying its SHA-256 checksum.
- Installs the latest Rancher CLI release.
- Reloads systemd and starts Jenkins.
- Verifies all installed tools both as root and as the `jenkins` user, including Docker access.
- Prints the Jenkins service status, installed versions, the Jenkins URL, and the initial administrator password when available.

The complete toolset installed by the script is:

```text
OpenJDK 21, Git, Docker, Docker Compose, AWS CLI v2,
Google Cloud CLI, GKE Authentication Plugin, Python 3,
Ansible, Boto3, Terraform, kubectl, and Rancher CLI
```

Rancher CLI is included only for pipelines that manage Rancher-managed Kubernetes resources; it is not required for the GCP VM or for GKE itself. The GKE authentication plugin is required when `kubectl` connects to GKE clusters.

The script is idempotent for package installation and can be rerun after a failed bootstrap. To run it manually on the VM:

```powershell
gcloud compute scp .\jenkinsdata.sh fashion-jenkins-server:/tmp/jenkinsdata.sh --zone=us-west1-b
gcloud compute ssh fashion-jenkins-server --zone=us-west1-b --command="sudo bash /tmp/jenkinsdata.sh"
```

## Run Jenkins for the first time

After Terraform finishes, open the printed URL in a browser:

```text
http://PUBLIC_IP:8080
```

Use `gcloud` to connect to the VM when terminal access is needed. No AWS `.pem` key is required:

```powershell
gcloud compute ssh fashion-jenkins-server --zone=us-west1-b
```

Confirm that Jenkins is installed and running:

```bash
sudo systemctl status jenkins
sudo systemctl is-enabled jenkins
sudo systemctl is-active jenkins
```

Retrieve the generated initial administrator password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Enter the password on the Unlock Jenkins page, select **Install suggested plugins**, and wait for the plugin installation to finish. Then create a new administrator account, save the Jenkins URL, and select **Start using Jenkins**. Never commit a Jenkins password or reuse a password shown in an example.

## Install CI/CD plugins

From the Jenkins dashboard, open **Manage Jenkins > Plugins > Available plugins**, search for each required plugin, and select **Install without restart**. Install the plugins required by this project’s pipeline, such as:

- GitHub Integration
- Docker Pipeline
- Docker plugin
- Git Push
- Copy Artifact
- JaCoCo
- AnsiColor
- Deploy to container
- Job DSL
- SonarQube Scanner
- Locale

The Git plugin is normally installed automatically with Jenkins. Review the **Installed plugins** tab after installation and restart Jenkins only if a plugin requests it.

## Verify and retrieve the initial password

List the VM and inspect the startup-script log:

```powershell
gcloud compute instances list
gcloud compute ssh YOUR_JENKINS_SERVER_NAME --zone=YOUR_ZONE --command="sudo systemctl status jenkins --no-pager; sudo tail -n 80 /var/log/cloud-init-output.log"
```

Check the startup service directly if Jenkins is missing:

```powershell
gcloud compute ssh YOUR_JENKINS_SERVER_NAME --zone=YOUR_ZONE --command="sudo journalctl -u google-startup-scripts.service --no-pager -n 100"
```

If the first bootstrap failed, copy and run the corrected script manually:

```powershell
gcloud compute scp .\jenkinsdata.sh YOUR_JENKINS_SERVER_NAME:/tmp/jenkinsdata.sh --zone=YOUR_ZONE
gcloud compute ssh YOUR_JENKINS_SERVER_NAME --zone=YOUR_ZONE --command="sudo bash /tmp/jenkinsdata.sh"
```

When Jenkins is active, retrieve the initial administrator password:

```powershell
gcloud compute ssh YOUR_JENKINS_SERVER_NAME --zone=YOUR_ZONE --command="sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```

Use that password at the Jenkins setup screen and then create the administrator account. Restrict the `jenkins-firewall` source ranges before using the server for production; the current configuration allows ports 22, 80, and 8080 from `0.0.0.0/0` for demonstration purposes.

## Changing projects or resetting state

Terraform state is project-specific. If `terraform.tfstate` references a previous project, do not run a normal plan until the state has been handled. To detach stale resources from local state without deleting them in Google Cloud:

```powershell
terraform state rm google_service_account.jenkins_sa google_project_iam_member.artifact_registry google_project_iam_member.gke_admin google_project_iam_member.logging google_project_iam_member.monitoring google_project_iam_member.storage_admin google_compute_instance.jenkins google_compute_firewall.jenkins_firewall
```

Use `terraform state rm` only when those addresses refer to the old project. Then run `terraform plan` and confirm the plan targets the current project. A clean new-project plan should show the Jenkins VM and firewall as additions, with no old-project destroys.

## Result and future CI/CD environments

The Jenkins server is now installed and prepared for the Fashion-Ethichal microservices CI/CD pipelines. The server can be provisioned with Terraform and recovered or configured manually through `gcloud compute ssh` when required. The startup script installs and verifies the main build, container, infrastructure, Kubernetes, and automation tools needed by the pipeline.

Jenkins can be used across Development, Testing, Staging, and Production environments. The planned GCP-based toolchain includes:

- GitHub or GitLab for source control and webhook-triggered builds.
- Maven for building the Spring microservices.
- Docker and Docker Compose for packaging and local or integration environments.
- Artifact Registry for storing Docker images and other build artifacts.
- Terraform for repeatable Google Cloud infrastructure provisioning.
- GKE, Kubernetes, and Helm for container orchestration and application releases.
- Cloud Deploy or Jenkins pipelines for progressive delivery between environments.
- Rancher for optional management of Rancher-managed Kubernetes clusters.
- Ansible for server and deployment automation.
- Cloud SQL for MySQL as the managed database equivalent of AWS RDS MySQL.
- Cloud Storage as the managed object-storage equivalent of AWS S3.
- Cloud DNS as the DNS equivalent of Amazon Route 53.
- Certificate Manager for TLS certificates as the GCP equivalent of AWS Certificate Manager.
- Cloud Monitoring and Cloud Logging, together with Prometheus and Grafana, for metrics, dashboards, and operational visibility.
- Selenium jobs for browser-based testing and JaCoCo for Java code coverage.
- SonarQube or another configured code-quality service for static analysis.

The AWS CLI v2 and `eksctl` are also installed for compatibility with pipelines that manage AWS or Amazon EKS resources, but they are not required for the GCP deployment. The GKE authentication plugin, `gcloud`, `kubectl`, and Helm are the GCP/Kubernetes tools used for GKE deployments; install Helm separately on the Jenkins VM if a pipeline invokes it.

## Destroy the environment

To remove the VM and firewall rule created by this configuration:

```powershell
terraform destroy
```

Review the plan and enter `yes` when prompted.