#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io curl
systemctl enable docker
systemctl start docker

docker run --pull=always --rm -d \
  -p 8080:8080 \
  --user=root \
  -e MICRONAUT_ENVIRONMENTS=google-compute \
  kestra/kestra:latest server standalone
