output "batch_pool_id" {
  value       = azurerm_batch_pool.kestra_batch_pool.name
  description = "Pool ID"
}