/*-----------------------------------------------------
Terraform init
-----------------------------------------------------*/
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.61.0"
    }
  }
  backend "azurerm" {
    subscription_id      = "ae92e392-3813-45dd-9c54-fe320939f03c"
    resource_group_name  = "rg-tervo-test-01"
    storage_account_name = "tfstates"
    container_name       = "tfstate-dev"
    key                  = "dev.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = "ae92e392-3813-45dd-9c54-fe320939f03c"
}

resource "azurerm_storage_account" "tf_state_account" {
  name                     = replace("tfstates${var.project}${var.environment}", "/[^0-9a-z]/", "")
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "tf_state_container" {
  name                  = "tfstate-${var.project}-${var.environment}"
  storage_account_name  = azurerm_storage_account.tf_state_account.name
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}