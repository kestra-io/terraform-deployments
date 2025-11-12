variable "project_id" {
  description = "The GCP project where resources will be created"
  type        = string
}

variable "region" {
  description = "Region for resources"
  type        = string
  default     = "europe-west1"
}

variable "vpc_network" {
  description = "VPC network name where resources will be deployed"
  type        = string
  default     = "mnw"
}

variable "zone" {
  description = "Zone for VM"
  type        = string
  default     = "europe-west1-b"
}

variable "bucket_name" {
  description = "Name of the GCS bucket for Kestra storage"
  type        = string
}

variable "db_instance_name" {
  description = "Cloud SQL instance identifier"
  type        = string
  default     = "kestra-db"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "kestra"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "kestra"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_tier" {
  description = "Machine type for Cloud SQL"
  type        = string
  default     = "db-f1-micro"
}

variable "machine_type" {
  description = "Machine type for the Kestra VM"
  type        = string
  default     = "e2-medium"
}

variable "basic_auth_user" {
  description = "Kestra UI basic auth username"
  type        = string
  default     = "admin@kestra.io"
}

variable "basic_auth_password" {
  description = "Kestra UI basic auth password"
  type        = string
  sensitive   = true
}

variable "ui_cidr" {
  description = "CIDR range allowed for Kestra UI access (e.g., 0.0.0.0/0 or x.x.x.x/32)"
  type        = string
}

variable "subnet_cidr_range" {
  description = "The CIDR range for the Kestra subnet (e.g., 10.0.50.0/24)"
  type        = string
}