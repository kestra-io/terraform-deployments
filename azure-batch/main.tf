terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "kestra_resource_group" {
  name = "kestra-resource-group"
}

data "azurerm_batch_account" "kestra_batch_account" {
  name                = "kestra-batch-account"
  resource_group_name = data.azurerm_resource_group.kestra_resource_group.name
}

resource "azurerm_batch_pool" "kestra_batch_pool" {
  name                = "azure_batch_task_runner"
  resource_group_name = data.azurerm_resource_group.kestra_resource_group.name
  account_name        = data.azurerm_batch_account.kestra_batch_account.name
  display_name        = "Kestra Batch Task Runner Pool"
  vm_size             = "Standard_A1_V2"
  node_agent_sku_id   = "batch.node.ubuntu 20.04"
  stop_pending_resize_operation = true

  container_configuration {
    type = "DockerCompatible"
  }

  auto_scale {
    evaluation_interval = "PT5M"

    formula = <<EOF
startingNumberOfVMs = 1;
maxNumberofVMs = 25;
pendingTasks = avg($PendingTasks.GetSample(1));
pendingTaskSamplePercent = $PendingTasks.GetSamplePercent(180 * TimeInterval_Second);
avgPendingOverThreeMin = avg($PendingTasks.GetSample(180 *   TimeInterval_Second, 0));
targetDedicatedNodesBasedOnPending = pendingTaskSamplePercent < 70 ? startingNumberOfVMs : pendingTasks > 0 ? max(1, avgPendingOverThreeMin) : 0;
$TargetDedicatedNodes=min(maxNumberofVMs, targetDedicatedNodesBasedOnPending);
$NodeDeallocationOption = taskcompletion;
EOF
  }

  storage_image_reference {
    publisher = "microsoft-azure-batch"
    offer     = "ubuntu-server-container"
    sku       = "20-04-lts"
    version   = "latest"
  }
}