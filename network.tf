resource "google_compute_network" "vpc" {
  name = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private" {
  name = "private-subnet"
  network = google_compute_network.vpc.id
  region = var.region
  ip_cidr_range = "10.10.0.0/20"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "public" {
  name = "public-subnet"
  network = google_compute_network.vpc.id
  region = var.region
  ip_cidr_range = "10.20.0.0/20"
}

resource "google_compute_router" "router" {
  name = "cloud-router"
  network = google_compute_network.vpc.id
  region = var.region
}

resource "google_compute_router_nat" "nat" {
  name = "cloud-nat"
  router = google_compute_router.router.name
  region = var.region
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
