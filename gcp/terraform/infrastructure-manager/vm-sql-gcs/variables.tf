variable "project_id" {
  description = "GCP project where resources will be created."
  type        = string
}

variable "region" {
  description = "GCP region for all resources."
  type        = string
}

variable "zone" {
  description = "GCP zone for the VM."
  type        = string
}

variable "bucket_name" {
  description = "Name of the GCS bucket."
  type        = string
}

variable "db_user" {
  description = "Database username for Kestra."
  type        = string
}

variable "db_password" {
  description = "Database password for Kestra."
  type        = string
  sensitive   = true
}

variable "machine_type" {
  description = "VM instance type (e.g., e2-medium)."
  type        = string
  default     = "e2-medium"
}

variable "allowed_cidr" {
  description = "CIDR allowed for SSH and HTTP access."
  type        = string
  default     = "0.0.0.0/0"
}
