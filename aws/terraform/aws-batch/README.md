# Terraform AWS Batch Infrastructure

This Terraform script configures AWS resources necessary to run containerized batch jobs using AWS Batch. It includes setup for networking, security, IAM roles, and a compute environment for running the jobs on ECS Fargate.

## Prerequisites

- Terraform installed (v1.5+ recommended)
- AWS CLI configured with access credentials

## Resources Created

- **AWS Default VPC:** we use the default VPC and subnets in the specified region for networking.
- **AWS S3 Bucket Data Source:** we use an existing S3 bucket named `kestra-product-de`. Replace this name to match your S3 bucket or create one in Terraform.
- **AWS Security Group:** a security group for AWS Batch jobs with egress to the internet (required to be able to download public Docker images).
- **AWS IAM Roles and Policies:** IAM roles and policies for AWS Batch and ECS Task Execution, including permissions for S3 access.
- **AWS Batch Compute Environment:** a managed ECS Fargate compute environment named `kestraFargateEnvironment`.
- **AWS Batch Job Queue:** a job queue named `kestraJobQueue` for submitting batch jobs.

## Usage

1. **Initialization:** before deploying the infrastructure, initialize Terraform to download the required providers:

   ```bash
   terraform init
   ```

2. **Planning:** review the changes Terraform will perform to match your configuration:

   ```bash
   terraform plan
   ```

3. **Apply Configuration:** apply the Terraform configuration to create the AWS resources:

   ```bash
   terraform apply
   ```

4. **Outputs:** after successful deployment, Terraform will output the ARNs for the ECS Task Execution Role, ECS Task Role, Batch Job Queue, and Batch Compute Environment that you can add to your AWS Batch task runner in Kestra.

## Customization

- **S3 Bucket:** The script references an existing S3 bucket. To create a new bucket, replace the data source with a resource block.
- **Region and Profile:** Configured for `eu-central-1` and the `kestra` AWS CLI profile. Adjust these values as needed for your setup.

For further customization, modify the Terraform scripts according to your project's requirements.

## Cleanup

To remove the AWS resources created by this script, use:

```bash
terraform destroy
```

Ensure all resources are appropriately cleaned up to avoid unnecessary charges.

## Support

For questions or issues regarding the use of this setup, reach out to us via Slack: https://kestra.io/slack.