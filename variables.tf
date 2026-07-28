variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP Region"
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "GCP Zone"
}

variable "cluster_name" {
  type        = string
  default     = "prod-gke"
  description = "GKE Cluster name"
}

variable "network_name" {
  type        = string
  default     = "prod-vpc"
  description = "VPC Network name"
}

variable "machine_type" {
  type        = string
  default     = "e2-standard-4"
  description = "Machine type for node pool"
}
