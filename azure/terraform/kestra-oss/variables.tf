variable "subscription_id" {
  description = "The Azure Subscription ID to deploy resources into"
}

variable "location" {
  description = "Azure region"
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "kestra-terraform-rg"
}

variable "admin_vm_username" {
  description = "VM Admin Username"
  default     = "kestra"
}

variable "admin_vm_password" {
  description = "VM Admin Password (not used if SSH key provided, but required by Azure API)"
  sensitive   = true
  default     = "ChangeMe123!"
}

variable "ssh_public_key" {
  description = "SSH Public Key"
}

variable "postgres_password" {
  description = "Password for the PostgreSQL database"
  sensitive   = true
}

variable "kestra_password" {
  description = "Password for Kestra Web UI"
  sensitive   = true
}

variable "authorized_source_ip" {
  description = "IP address/CIDR allowed to access SSH and Kestra Web. Use * for all."
  default     = "*"
}

variable "db_sku_name" {
  description = "The SKU Name for the PostgreSQL Flexible Server. Examples: B_Standard_B1ms, GP_Standard_D2ds_v4, MO_Standard_E4s_v3"
  default     = "B_Standard_B1ms"
}