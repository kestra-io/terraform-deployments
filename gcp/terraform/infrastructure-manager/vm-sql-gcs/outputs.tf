output "kestra_ui" {
  description = "Public URL of the Kestra UI"
  value       = "http://${google_compute_instance.kestra_vm.network_interface[0].access_config[0].nat_ip}:8080"
}

output "bucket_name" {
  value = google_storage_bucket.kestra_bucket.name
}

output "db_connection_name" {
  value = google_sql_database_instance.kestra_db.connection_name
}
