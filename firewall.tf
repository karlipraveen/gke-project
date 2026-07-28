resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "http" {
  name = "allow-http"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports = ["80","443"]
  }
  source_ranges = ["0.0.0.0/0"]
}
