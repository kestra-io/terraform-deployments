terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Storage bucket for Kestra
resource "google_storage_bucket" "kestra_bucket" {
  name     = var.bucket_name
  location = var.region
  force_destroy = true
}

# Cloud SQL (PostgreSQL)
resource "google_sql_database_instance" "kestra_db" {
  name             = "kestra-db"
  database_version = "POSTGRES_15"
  region           = var.region
  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_user" "kestra_user" {
  instance = google_sql_database_instance.kestra_db.name
  name     = var.db_user
  password = var.db_password
}

# Compute Engine instance
resource "google_compute_instance" "kestra_vm" {
  name         = "kestra-vm"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts"
      size  = 30
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("${path.module}/startup.sh")

  tags = ["kestra"]
}

# Firewall rules (for SSH + UI)
resource "google_compute_firewall" "kestra_firewall" {
  name    = "kestra-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "8080"]
  }

  source_ranges = [var.allowed_cidr]
}
