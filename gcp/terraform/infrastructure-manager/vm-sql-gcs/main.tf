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

  settings {
    tier               = var.db_tier
    edition            = "ENTERPRISE"
    availability_type  = "ZONAL"
    disk_type          = "PD_SSD"
    disk_size          = 30
  }

  deletion_protection = false
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

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e

    apt-get update -y
    apt-get install -y docker.io curl
    systemctl enable docker
    systemctl start docker

    cat <<EOC > /home/ubuntu/application-gcp-vm.yaml
    datasources:
      postgres:
        url: jdbc:postgresql://${google_sql_database_instance.kestra_db.connection_name}:5432/${var.db_name}
        driverClassName: org.postgresql.Driver
        username: ${var.db_user}
        password: ${var.db_password}
    kestra:
      server:
        basic-auth:
          enabled: true
          username: ${var.basic_auth_user}
          password: ${var.basic_auth_password}
      repository:
        type: postgres
      storage:
        type: gcs
        gcs:
          bucket: ${google_storage_bucket.kestra_bucket.name}
      queue:
        type: postgres
      tasks:
        tmp-dir:
          path: "/tmp/kestra-wd/tmp"
      url: "http://localhost:8080/"
    EOC

    docker run --pull=always --rm -d \
      -p 8080:8080 \
      --user=root \
      -e MICRONAUT_ENVIRONMENTS=google-compute \
      -v /home/ubuntu/application-gcp-vm.yaml:/etc/config/application-gcp-vm.yaml \
      -v /var/run/docker.sock:/var/run/docker.sock \
      --name kestra \
      kestra/kestra:latest server standalone --config /etc/config/application-gcp-vm.yaml

    echo "Kestra server started" > /home/ubuntu/READY.txt
  EOF

  deletion_protection = false
  tags = ["kestra"]
}
