# Kestra Terraform GCP + Aiven Example Repo 

This repository holds examples of deploying Kestra using Terraform/OpenTofu on Google Cloud Platform with Aiven providing the data backend. 

The repository is split into 2 flavours: 

 - Kestra Open Source Edition with Aiven for Postgres®

 - Kestra Enterprise with Aiven for Kafka® and Aiven for Opensearch®

 ## Requirements

For both deployment types the following are required

- An active Google Cloud Platform (GCP) subscription

- A service account in GCP which has permissions to create Compute and Network resources

- An active Aiven subscription and API Token. https://aiven.io/docs/platform/concepts/authentication-tokens

For Kestra Enterprise the following are also required

- Kesrta Enterprise license (license-id, license-key and fingerprint)

- Terraform or OpenTofu installed on local machine

## Installation

1. Choose either the `opensource` or `enterprise` edition folder. 

2. Download the service account JSON file from your Google account and set the environment variable `GOOGLE_APPLICATION_CREDENTIALS`.

```
export GOOGLE_APPLICATION_CREDENTIALS=credentials.json
```

3. Fill out `terraform.tfvars.example` with the values appropriate for your deployment and rename to `terraform.tfvars`. 

4. Initialize the provider, `terraform init` or `tofu init`. 

5. Verify deployment with either `terraform plan` or `tofu plan`. 

6. Apply deployment with either `terraform apply` or `tofu apply`. 

7. Log into Kestra server using provided URL after deployment completes, e.g. 

```
Outputs:

web-server-url = "http://12.34.567.89:8080"
```
