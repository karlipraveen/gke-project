output "cluster_name" {
  value = google_container_cluster.gke.name
}

output "endpoint" {
  value = google_container_cluster.gke.endpoint
}

output "network" {
  value = google_compute_network.vpc.name
}

output "subnet" {
  value = google_compute_subnetwork.private.name
}
