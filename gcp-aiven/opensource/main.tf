terraform {
  required_providers {
    aiven = {
      source  = "aiven/aiven"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "aiven" {
  api_token = var.aiven_api_token
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "null_resource" "deploy_app" {
  depends_on = [google_compute_instance.kestra_vm]
  provisioner "file" {
    content = templatefile("${path.module}/scripts/docker-compose.yml.tftpl", {
      kestra-version  = "v${var.kestra_version}-full",
      kestra-username = var.kestra_username,
      kestra-password = var.kestra_password,
      pg-jdbc         = "jdbc:postgresql://${aiven_pg.postgres.service_host}:${aiven_pg.postgres.service_port}/${var.aiven_db}",
      pg-username     = aiven_pg.postgres.service_username,
      pg-password     = aiven_pg.postgres.service_password
    })
    destination = "/app/docker-compose.yml"
    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.ssh_private_key)
      host        = google_compute_instance.kestra_vm.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "docker-compose -f /app/docker-compose.yml up -d"
    ]
    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.ssh_private_key)
      host        = google_compute_instance.kestra_vm.network_interface[0].access_config[0].nat_ip
    }
  }
}

// A variable for extracting the external IP address of the VM
output "web-server-url" {
  value = join("", ["http://", google_compute_instance.kestra_vm.network_interface.0.access_config.0.nat_ip, ":8080"])
}