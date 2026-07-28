resource "google_container_cluster" "gke" {
  name = var.cluster_name
  location = var.region
  network = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.private.id
  remove_default_node_pool = true
  initial_node_count = 1
  networking_mode = "VPC_NATIVE"
  deletion_protection = false
  enable_shielded_nodes = true
  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {}

  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = false
  }
  resource_labels = local.labels
}

resource "google_container_node_pool" "primary" {
  name = "primary-nodepool"
  cluster = google_container_cluster.gke.name
  location = var.region
  node_count = 3
  autoscaling {
    min_node_count = 3
    max_node_count = 6
  }

  management {
    auto_upgrade = true
    auto_repair = true
  }

  node_config {
    machine_type = var.machine_type
    disk_size_gb = 100
    disk_type = "pd-balanced"
    service_account = google_service_account.gke_sa.email
    labels = local.labels
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
