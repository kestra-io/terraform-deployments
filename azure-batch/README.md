# Terraform Azure Batch Infrastructure

This Terraform script configures Azure resources necessary to run containerized batch jobs using Azure Batch. It includes node pool setup for running the jobs on a given Batch account.

## Prerequisites

- Terraform installed (v1.5+ recommended)
- Azure CLI configured with access credentials

## Resources Created

- **Azure Batch Node Pool:** a pool named `azure_batch_task_runner` with an auto-scaling based on the workload.

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

4. **Outputs:** after successful deployment, Terraform will output the Pool ID that you can add to your Azure Batch task runner in Kestra.

## Customization

- **Batch account:** The script references an existing Batch account. To create a new batch account, replace the data source with a resource block.
- **Resource group:** The script references a group named `kestra-resource-group`. To create a new batch account, replace the data source with a resource block.
- **Auto-scaling:** The created pool has auto-scaling configured based on the pending & active workload. This setup provide at least one node by default. Feel free to customize it or swap for a fixed scaling.
- **VM Sizing:** The default nodes' size is `Standard_A1_V2`.

For further customization, modify the Terraform scripts according to your project's requirements.

## Cleanup

To remove the Azure resources created by this script, use:

```bash
terraform destroy
```

Ensure all resources are appropriately cleaned up to avoid unnecessary charges.

## Support

For questions or issues regarding the use of this setup, reach out to us via Slack: https://kestra.io/slack.