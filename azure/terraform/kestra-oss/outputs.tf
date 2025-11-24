output "kestra_url" {
  value = "http://${azurerm_public_ip.pip.ip_address}:8080"
}

output "ssh_command" {
  value = "ssh ${var.admin_vm_username}@${azurerm_public_ip.pip.ip_address}"
}

output "db_hostname" {
  value = azurerm_postgresql_flexible_server.db.fqdn
}