# This Terraform template prepares a development environment
# for the Petclinic Microservices Application on Google Cloud.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}


# ------------------------------------------------------------
# Development Server
# ------------------------------------------------------------

resource "google_compute_instance" "PetclinicServer" {

  name         = var.devservertag
  machine_type = var.instance_type
  zone         = var.zone

  tags = ["petclinic-dev-server"]

  boot_disk {
    initialize_params {
      image = var.image
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    access_config {
      # Ephemeral public IP
    }
  }

  # Startup script
  metadata_startup_script = file("${path.module}/development-server-userdata.sh")

  # Optional SSH key
  metadata = {
    ssh-keys = "${var.ssh_user}:${file(pathexpand(var.public_key_file))}"
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}


# ------------------------------------------------------------
# Firewall Rules
# ------------------------------------------------------------

resource "google_compute_firewall" "dev-server-sg" {

  name    = var.devops_server_secgr
  network = var.network

  target_tags = [
    "petclinic-dev-server"
  ]

  dynamic "allow" {

    for_each = var.dev_server_ports

    content {

      protocol = "tcp"

      ports = [
        tostring(allow.value)
      ]
    }
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}


# ------------------------------------------------------------
# Egress
# ------------------------------------------------------------

resource "google_compute_firewall" "dev-server-egress" {

  name    = "${var.devops_server_secgr}-egress"
  network = var.network

  direction = "EGRESS"

  target_tags = [
    "petclinic-dev-server"
  ]

  allow {
    protocol = "all"
  }

  destination_ranges = [
    "0.0.0.0/0"
  ]
}


# ------------------------------------------------------------
# Output
# ------------------------------------------------------------

output "PetclinicServerExternalIP" {

  description = "External IP address of Petclinic development server"

  value = google_compute_instance.PetclinicServer.network_interface[0].access_config[0].nat_ip
}


output "PetclinicServerDNSName" {

  description = "DNS name of Petclinic development server"

  value = google_compute_instance.PetclinicServer.name
}


output "PetclinicServerInternalIP" {

  description = "Internal IP address of Petclinic development server"

  value = google_compute_instance.PetclinicServer.network_interface[0].network_ip
}