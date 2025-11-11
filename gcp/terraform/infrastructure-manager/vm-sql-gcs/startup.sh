#!/bin/bash
set -e

# Read parameters from metadata (injected via Terraform)
DB_HOST=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_host" -H "Metadata-Flavor: Google")
DB_NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_name" -H "Metadata-Flavor: Google")
DB_USER=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_user" -H "Metadata-Flavor: Google")
DB_PASS=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/db_password" -H "Metadata-Flavor: Google")
BUCKET_NAME=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/bucket_name" -H "Metadata-Flavor: Google")
REGION=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/region" -H "Metadata-Flavor: Google")
BASIC_AUTH_USER=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/basic_auth_user" -H "Metadata-Flavor: Google")
BASIC_AUTH_PASS=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/basic_auth_password" -H "Metadata-Flavor: Google")

# Install dependencies
apt-get update -y
apt-get install -y docker.io curl
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# Create Kestra configuration file
cat <<EOF > /home/ubuntu/application-gcp-marketplace.yaml
datasources:
  postgres:
    url: jdbc:postgresql://${DB_HOST}:5432/${DB_NAME}
    driverClassName: org.postgresql.Driver
    username: ${DB_USER}
    password: ${DB_PASS}
kestra:
  server:
    basic-auth:
      enabled: true
      username: ${BASIC_AUTH_USER}
      password: ${BASIC_AUTH_PASS}
  repository:
    type: postgres
  storage:
    type: gcs
    gcs:
      bucket: ${BUCKET_NAME}
      project-id: ${REGION}
  queue:
    type: postgres
  tasks:
    tmp-dir:
      path: "/tmp/kestra-wd/tmp"
  url: "http://localhost:8080/"
EOF

echo "Config file written to /home/ubuntu/application-gcp-marketplace.yaml"

# Run Kestra container
docker run --pull=always --rm -d \
  -p 8080:8080 \
  --user=root \
  -e MICRONAUT_ENVIRONMENTS=google-compute \
  -v /home/ubuntu/application-gcp-marketplace.yaml:/etc/config/application-gcp-marketplace.yaml \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name kestra \
  kestra/kestra:latest server standalone --config /etc/config/application-gcp-marketplace.yaml

echo "Kestra server started successfully" > /home/ubuntu/READY.txt
