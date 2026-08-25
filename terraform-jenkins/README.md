# Jenkins on Google Compute Engine

This Terraform configuration creates a Jenkins server on a Google Compute Engine VM. It uses the project’s existing default Compute Engine service account, assigns an ephemeral public IP, and opens SSH (22), HTTP (80), and Jenkins (8080) in the VPC firewall.

## Prerequisites

- A Google Cloud project with billing enabled.
- The Google Cloud CLI (`gcloud`) and Terraform (version 1.5 or newer).
- A Google account with permission to create Compute Engine instances and firewall rules.
- An existing VPC and subnet, or permission to use the project `default` network.

Authenticate locally and select the project:

```powershell
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login
```

Enable the APIs used by this configuration:

```powershell
gcloud services enable compute.googleapis.com iam.googleapis.com \
  artifactregistry.googleapis.com container.googleapis.com \
  logging.googleapis.com monitoring.googleapis.com
```

In PowerShell, use one line if the backslash continuation is not recognized:

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

## Verify and retrieve the initial password

List the VM and inspect the startup-script log:

```powershell
gcloud compute instances list
gcloud compute ssh YOUR_JENKINS_SERVER_NAME --zone=YOUR_ZONE --command="sudo systemctl status jenkins --no-pager; sudo tail -n 80 /var/log/cloud-init-output.log"
```

When Jenkins is active, retrieve the initial administrator password:

```powershell
gcloud compute ssh YOUR_JENKINS_SERVER_NAME --zone=YOUR_ZONE --command="sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```

Use that password at the Jenkins setup screen and then create the administrator account. Restrict the `jenkins-firewall` source ranges before using the server for production; the current configuration allows ports 22, 80, and 8080 from `0.0.0.0/0` for demonstration purposes.

## Destroy the environment

To remove the VM and firewall rule created by this configuration:

```powershell
terraform destroy
```

Review the plan and enter `yes` when prompted.