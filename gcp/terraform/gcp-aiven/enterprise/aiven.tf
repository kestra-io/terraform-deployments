resource "aiven_kafka" "kestra_kafka" {
  project                 = var.aiven_project
  service_name            = "kestra-kafka"
  cloud_name              = var.aiven_region
  plan                    = var.aiven_kafka_plan
  maintenance_window_dow  = "monday"
  maintenance_window_time = "10:00:00"
}

resource "aiven_opensearch" "kestra_os" {
  project                 = var.aiven_project
  service_name            = "kestra-os"
  cloud_name              = var.aiven_region
  plan                    = var.aiven_os_plan
  maintenance_window_dow  = "monday"
  maintenance_window_time = "10:00:00"
}