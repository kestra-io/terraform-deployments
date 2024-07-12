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

resource "null_resource" "deploy_config" {
  depends_on = [google_compute_instance.kestra_vm, aiven_kafka.kestra_kafka]

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.config/aiven",
      "mkdir -p ~/.docker"
    ]
    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.ssh_private_key)
      host        = google_compute_instance.kestra_vm.network_interface[0].access_config[0].nat_ip
    }
  }
  provisioner "file" {
    content = templatefile("${path.module}/config/aiven-client.json.tftpl", {
      aiven_project = var.aiven_project
    })
    destination = "/home/${var.ssh_username}/.config/aiven/aiven-client.json"
    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.ssh_private_key)
      host        = google_compute_instance.kestra_vm.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "file" {
    content = templatefile("${path.module}/config/aiven-credentials.json.tftpl", {
      auth_token = var.aiven_api_token,
      email      = var.kestra_username #assume kestra username is same email
    })
    destination = "/home/${var.ssh_username}/.config/aiven/aiven-credentials.json"
    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.ssh_private_key)
      host        = google_compute_instance.kestra_vm.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "file" {
    content = templatefile("${path.module}/config/docker.config.tftpl", {
      docker-private-repo = var.docker_repo,
      docker_creds = var.docker_creds
    })
    destination = "/home/${var.ssh_username}/.docker/config.json"
    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.ssh_private_key)
      host        = google_compute_instance.kestra_vm.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "/usr/local/bin/avn service user-kafka-java-creds kestra-kafka --username avnadmin --password safePassword123 -d /app/ssl"
    ]
    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.ssh_private_key)
      host        = google_compute_instance.kestra_vm.network_interface[0].access_config[0].nat_ip
    }
  }
}

resource "null_resource" "deploy_app" {
  depends_on = [null_resource.deploy_config, aiven_kafka.kestra_kafka, aiven_opensearch.kestra_os]
  provisioner "file" {
    content = templatefile("${path.module}/scripts/docker-compose.yml.tftpl", {
      kestra-version      = "v${var.kestra_version}-full",
      kestra-username     = var.kestra_username,
      kestra-password     = var.kestra_password,
      license-id          = var.kestra_license_id,
      license-key         = var.kestra_license_key,
      encryption-key      = var.kestra_encryption_key,
      opensearch-uri      = aiven_opensearch.kestra_os.service_uri,
      opensearch-username = aiven_opensearch.kestra_os.service_username,
      opensearch-password = aiven_opensearch.kestra_os.service_password,
      bootstrap-server    = aiven_kafka.kestra_kafka.service_uri

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