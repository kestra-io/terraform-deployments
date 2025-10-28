resource "aiven_pg" "postgres" {
  project                 = var.aiven_project
  service_name            = "kestra-pg"
  cloud_name              = var.aiven_region
  plan                    = var.aiven_pg_plan
  maintenance_window_dow  = "monday"
  maintenance_window_time = "10:00:00"
}

resource "aiven_pg_database" "pg-db" {
  project       = var.aiven_project
  service_name  = aiven_pg.postgres.service_name
  database_name = var.aiven_db
}