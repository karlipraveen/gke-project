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
gcloud compute ssh Development-Server --zone=asia-southeast1-a
docker --version    # Verify the Docker
java -version       # Java
git --version       # Git

# Repository
ls -la /home/devops/microservices-with-db-on-dev-server