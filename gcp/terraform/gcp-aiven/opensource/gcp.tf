resource "google_compute_firewall" "kestra-public" {
  name      = "public-egress"
  network   = var.gcp_vpc
  direction = "INGRESS"
  priority  = 0

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  destination_ranges = [var.webserver_cidr_range]
  source_tags        = ["kestra-web"]
}

resource "google_compute_instance" "kestra_vm" {
  name         = "kestra-webserver"
  machine_type = "e2-medium"
  zone         = var.region

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = var.gcp_vpc
    access_config {

    }
  }
  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key)}"
  }

  tags = ["kestra-web", "http-server", "https-server"]

  # metadata_startup_script = file("${path.module}/scripts/startup.sh")
  metadata_startup_script = templatefile("${path.module}/scripts/startup.sh", {
    username       = var.ssh_username,
    kestra_version = var.kestra_version
  })
}
