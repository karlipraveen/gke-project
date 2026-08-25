resource "google_compute_instance" "jenkins" {
  name         = var.jenkins_server_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["jenkins"]

  boot_disk {
    initialize_params {
      image = var.image
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    access_config {}
  }

  metadata = {
    startup-script = file(var.startup_script)
  }
}
