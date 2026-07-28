output "cluster_name" {
  value       = google_container_cluster.gke.name
  description = "GKE Cluster name"
}

output "endpoint" {
  value       = google_container_cluster.gke.endpoint
  description = "GKE Cluster endpoint"
}

output "network" {
  value       = google_compute_network.vpc.name
  description = "VPC Network name"
}

output "subnet" {
  value       = google_compute_subnetwork.private.name
  description = "Private subnet name"
}

output "service_account_email" {
  value       = google_service_account.gke_sa.email
  description = "GKE Node Service Account email"
}

output "service_account_id" {
  value       = google_service_account.gke_sa.unique_id
  description = "GKE Node Service Account unique ID"
}