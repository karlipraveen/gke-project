variable "project_id" {}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "cluster_name" {
  default = "prod-gke"
}

variable "network_name" {
  default = "prod-vpc"
}

variable "machine_type" {
  default = "e2-standard-4"
}
