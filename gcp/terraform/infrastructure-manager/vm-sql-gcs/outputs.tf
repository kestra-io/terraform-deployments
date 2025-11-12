output "kestra_vm_ip" {
  description = "External IP address of the Kestra VM"
  value       = google_compute_instance.kestra_vm.network_interface[0].access_config[0].nat_ip
}

output "kestra_ui_url" {
  description = "Kestra UI access URL"
  value       = "http://${google_compute_instance.kestra_vm.network_interface[0].access_config[0].nat_ip}:8080"
}

output "gcs_bucket_name" {
  description = "Name of the GCS bucket used for Kestra storage"
  value       = google_storage_bucket.kestra_bucket.name
}

output "db_private_ip" {
  value = google_sql_database_instance.kestra_db.private_ip_address
}
