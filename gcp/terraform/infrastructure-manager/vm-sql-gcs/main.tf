terraform {
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

resource "google_compute_subnetwork" "kestra_subnet" {
  name          = "kestra-subnet-infra-manager"
  ip_cidr_range = "10.0.50.0/24"
  region        = var.region
  network       = "projects/${var.project_id}/global/networks/mnw"
  private_ip_google_access = true
}

# ---------------------------
#  GCS bucket for Kestra
# ---------------------------
resource "google_storage_bucket" "kestra_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true
}

# ---------------------------
#  Cloud SQL (PostgreSQL)
# ---------------------------
resource "google_sql_database_instance" "kestra_db" {
  name             = var.db_instance_name
  database_version = "POSTGRES_17"
  region           = var.region
  deletion_protection = false

  settings {
    tier = "db-custom-1-3840"
    edition = "ENTERPRISE"

    ip_configuration {
      ipv4_enabled    = false
      private_network = "projects/${var.project_id}/global/networks/${var.vpc_network}"
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled = false
    }
  }
}

resource "google_sql_database" "kestra_database" {
  name     = var.db_name
  instance = google_sql_database_instance.kestra_db.name
}

resource "google_sql_user" "kestra_user" {
  name     = var.db_user
  instance = google_sql_database_instance.kestra_db.name
  password = var.db_password
}

# ---------------------------
#  Firewall for SSH + Kestra UI
# ---------------------------
resource "google_compute_firewall" "kestra_firewall" {
  name    = "kestra-allow-ssh-ui"
  network = "mnw"

  allow {
    protocol = "tcp"
    ports    = ["22", "8080"]
  }

  source_ranges = [var.ssh_cidr]
  direction     = "INGRESS"
  description   = "Allow SSH (22) and Kestra UI (8080) from configured CIDR"
}

# ---------------------------
#  Compute Engine (Kestra VM)
# ---------------------------
resource "google_compute_instance" "kestra_vm" {
  name         = "kestra-vm"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
    }
  }

  network_interface {
    network    = "projects/${var.project_id}/global/networks/mnw"
    subnetwork = google_compute_subnetwork.kestra_subnet.id

    access_config {
      network_tier = "PREMIUM"
    }
  }

  metadata_startup_script = templatefile("${path.module}/startup.sh.tmpl", {
    db_host             = google_sql_database_instance.kestra_db.private_ip_address
    db_name             = var.db_name
    db_user             = var.db_user
    db_password         = var.db_password
    basic_auth_user     = var.basic_auth_user
    basic_auth_password = var.basic_auth_password
    bucket_name         = google_storage_bucket.kestra_bucket.name
  })

  deletion_protection = false
  tags = ["kestra"]
}
