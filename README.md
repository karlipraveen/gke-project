# gke-project
Microservices with DB on Development setup

Below is a **production-ready Terraform project** to create a **private GKE cluster **with:
✅ Custom VPC
✅ Public & Private Subnets
✅ Cloud Router
✅ Cloud NAT
✅ GKE Cluster
✅ Managed Node Pool
✅ Service Account
✅ IAM Roles
✅ Firewall Rules
✅ Labels
✅ Outputs

This closely matches your AWS Terraform project structure.

terraform-gke/
│
├── provider.tf
├── variables.tf
├── terraform.tfvars
├── locals.tf
├── network.tf
├── iam.tf
├── gke.tf
├── firewall.tf
├── outputs.tf
└── versions.tf

IAM Roles Used:
Role	                            Purpose
roles/logging.logWriter	          Write Cloud Logging logs
roles/monitoring.metricWriter	    Send metrics to Cloud Monitoring
roles/artifactregistry.reader	    Pull container images
roles/storage.objectViewer	      Read objects from Cloud Storage

Optional production roles:
Depending on your workloads, you may also grant:
roles/secretmanager.secretAccessor – access secrets from Secret Manager.
roles/cloudsql.client – connect securely to Cloud SQL.
roles/pubsub.publisher / roles/pubsub.subscriber – interact with Pub/Sub.
roles/container.developer – limited GKE management permissions.
roles/container.admin – full GKE administration (typically for platform admins only).

Deploy:
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply

Verify:
gcloud container clusters get-credentials prod-gke --region us-central1 --project my-gcp-project
kubectl get nodes
kubectl get pods -A
