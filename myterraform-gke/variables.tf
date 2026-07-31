variable "project_id" {
  type        = string
  description = "GCP Project ID"

  validation {
    condition     = length(trim(var.project_id, " ")) > 0
    error_message = "project_id must not be empty."
  }
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP Region"

  validation {
    condition     = length(trim(var.region, " ")) > 0
    error_message = "region must not be empty."
  }
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "GCP Zone"

  validation {
    condition     = length(trim(var.zone, " ")) > 0
    error_message = "zone must not be empty."
  }
}

variable "cluster_name" {
  type        = string
  default     = "prod-gke"
  description = "GKE Cluster name"

  validation {
    condition     = length(trim(var.cluster_name, " ")) > 0
    error_message = "cluster_name must not be empty."
  }
}

variable "network_name" {
  type        = string
  default     = "prod-vpc"
  description = "VPC Network name"

  validation {
    condition     = length(trim(var.network_name, " ")) > 0
    error_message = "network_name must not be empty."
  }
}

variable "machine_type" {
  type        = string
  default     = "e2-standard-4"
  description = "Machine type for node pool"

  validation {
    condition     = length(trim(var.machine_type, " ")) > 0
    error_message = "machine_type must not be empty."
  }
}
