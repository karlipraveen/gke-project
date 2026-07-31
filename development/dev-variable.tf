variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "image" {
  description = "GCP boot disk image"
  type        = string
}

variable "instance_type" {
  description = "GCP Compute Engine machine type"
  type        = string
}

variable "network" {
  description = "GCP VPC network"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "GCP subnetwork"
  type        = string
  default     = "default"
}

variable "devops_server_secgr" {
  description = "Firewall rule name"
  type        = string
}

variable "dev_server_ports" {
  type        = list(number)
  description = "Development server inbound TCP ports"
}

variable "devservertag" {
  description = "Development server name"
  type        = string
}

variable "ssh_user" {
  description = "Linux SSH username"
  type        = string
  default     = "devops"
}

variable "public_key_file" {
  description = "Path to SSH public key"
  type        = string
}