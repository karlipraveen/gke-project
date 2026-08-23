# Authenticate:
gcloud auth application-default login

# Set the project:
gcloud config set project YOUR_PROJECT_ID

# Enable Compute Engine:
gcloud services enable compute.googleapis.com

terraform init      # Intialize
terraform fmt       # 
terraform validate  # validate
terraform plan      # Plan
terraform apply     # Deploy

# Verify the VM
gcloud compute instances list 

# Get the IP
terraform output PetclinicServerExternalIP

# SSH to the Development server
gcloud compute ssh development-server --zone=asia-southeast1-a
docker --version    # Verify the Docker
java -version       # Java
git --version       # Git

# Repository
ls -la /home/devops/microservices-with-db-on-dev-server
=========================================================
I’m reviewing the Terraform definitions again so I can list the Google Cloud resources this configuration will create and then outline how to validate them after deployment.

Google Cloud resources this Terraform will create
Based on dev-server.tf and dev.auto.tfvars, the deployment will create these GCP resources:

1. Compute Engine instance
    Name: Development-Server
    Zone: asia-southeast1-a
    Machine type: e2-medium
    Image: Ubuntu 22.04 LTS
    Boot disk: 30 GB, pd-balanced
    Network: default
    Public IP: assigned automatically

2. Firewall rule
    Name: development-server-firewall
    Allows inbound TCP on ports: 22, 80, 8000, 8080, 9090, 8081, 8082, 8083, 8888, 9411, 7979, 3000, 9091, 8761
    Source range: 0.0.0.0/0

3. Egress firewall rule
    Name: development-server-firewall-egress
    Allows all outbound traffic

Validation after creation
I verified earlier that the Terraform configuration is valid with "terraform validate", which returned success. After you apply it, use these commands to validate the real GCP resources:

1) Check the VM exists
gcloud compute instances list --filter="name='Development-Server'"

2) Inspect the VM details
gcloud compute instances describe Development-Server --zone=asia-southeast1-a

3) Check firewall rules
gcloud compute firewall-rules list --filter="name~'development-server-firewall'"

4) Verify the startup script worked
gcloud compute ssh Development-Server --zone=asia-southeast1-a --command="docker --version && java -version && git --version"

5) Confirm Terraform outputs
terraform -chdir="development" output

Apply command
If you want to create the resources now:
# terraform -chdir="development" apply -var-file=dev.auto.tfvars -auto-approve

If you want, I can next help you run the apply and verify the resources step by step.


I’m starting the deployment and then I’ll verify the created resources directly in Google Cloud so you have fresh evidence.
# terraform apply -var-file=dev.auto.tfvars -auto-approve -input=false


The initial deployment command hit a Terraform CLI argument issue, so I’m rerunning it with the working-directory flag that the CLI expects on this environment.
# terraform -chdir="c:\Users\user\OneDrive\Desktop\gke-project\development" apply -var-file="dev.auto.tfvars" -auto-approve -input=false

The deployment is being blocked by a missing SSH public key file, so I’m generating the key first and then re-running the apply against the lab project.
New-Item -ItemType Directory -Force -Path "$HOME/.ssh" | Out-Null; if (-not (Test-Path "$HOME/.ssh/id_rsa")) { ssh-keygen -t rsa -b 2048 -f "$HOME/.ssh/id_rsa" -N '' -C 'devops' -q }; if (Test-Path "$HOME/.ssh/id_rsa.pub") { Get-Content "$HOME/.ssh/id_rsa.pub" }


The SSH key generation command needed a different invocation for this shell, so I’m retrying with a PowerShell-compatible approach.
# sshDir = "$HOME/.ssh"; New-Item -ItemType Directory -Force -Path $sshDir | Out-Null; if (-not (Test-Path "$sshDir/id_rsa")) { & ssh-keygen -t rsa -b 2048 -f "$sshDir/id_rsa" -N '""' -C 'devops' -q }; if (Test-Path "$sshDir/id_rsa.pub") { Get-Content "$sshDir/id_rsa.pub" }


The apply is failing at the authentication layer rather than Terraform syntax, so I’m checking the active Google Cloud account state now to resolve that cleanly.
# gcloud auth list --format='value(account,status)' ; echo '---' ; gcloud config get-value project


The deployment is currently blocked by Google authentication, and I’m switching to the CLI’s Windows entrypoint so I can confirm the account state and fix it directly.
& "$env:USERPROFILE\AppData\Local\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd" auth list --format='value(account,status)'



### 1. Log in with the Qwiklabs account:
```
gcloud auth login student-04-9b6554964350@qwiklabs.net
gcloud auth list    <==To verify
```

### 2. After logging in, you can check ADC with:
If you're using Terraform or other applications that use ADC, update it:
```
gcloud auth application-default set-quota-project qwiklabs-gcp-04-818836f7de03
gcloud auth application-default print-access-token
```
Note: If you're using Terraform, client libraries, or applications that rely on ADC, you may need to refresh those credentials too.

### 3. To switch to the other account
```
gcloud config set account student-03-f003804322e4@qwiklabs.net
gcloud config list      <== To verify
```

### 4. To remove an account from stored credentials
```
gcloud auth revoke student-03-b14b75fb8d5f@qwiklabs.net
gcloud auth list        <== To verify
gcloud config set account student-03-b14b75fb8d5f@qwiklabs.net
gcloud auth list        <== your current project is qwiklabs-gcp-04-c385bcd0f66a
gcloud config list      <== your current project is qwiklabs-gcp-04-c385bcd0f66a
```

### Check available VM instances and SSH into the VM:
```
gcloud compute instances list
gcloud compute ssh VM_NAME --zone=ZONE
```

### Quick flow to remember:
### Login → Auth List → Set Project → Config List → Instance List → SSH.

### Important distinction
* `gcloud config set account ...` → changes the **active account** for the current configuration.
* `gcloud auth revoke ...` → removes/revokes the account's stored authentication credentials.
* `gcloud config unset account` → removes the account setting from the current configuration, but **doesn't revoke the credentials**.
