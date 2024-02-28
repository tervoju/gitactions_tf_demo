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
    resource_group_name  = "rg-tervo-tf-state"
    storage_account_name = "devtervotfstatestorage"
    container_name       = "tfstate"
    key                  = "dev-tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = "3a2b621e-1c4c-431b-9cfc-614bd2c5649d"
}

data "azurerm_client_config" "current" {}

/*-----------------------------------------------------
Azure Function App
-----------------------------------------------------*/

module "function_app" {
  source              = "./../modules/function-app"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  project             = var.project
  appname             = var.appname
  python_version      = "3.11"
  app_settings = {
    KEY_VAULT_URL                  = "https://${module.key_vault.key_vault_name}.vault.azure.net/"
    EVENT_HUB_NAMESPACE_FQDN       = ""
    BLOB_STORAGE_ACCOUNT_URL       = ""
    BLOB_CONTAINER_CHECKPOINT_NAME = ""
    EVENT_HUB_METSA                = module.event_hub_metsa.name
  }
}

/*----------------------------------------------------------------
KEY VAULT 
----------------------------------------------------------------*/
module "key_vault" {
  source              = "./../modules/key-vault"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  project             = var.project
  appname             = var.function_app_name
}

# Allow the Function App to read the Secrets
resource "azurerm_role_assignment" "secrets_user" {
  scope                = module.key_vault.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.function_app.principal_id
}

resource "azurerm_key_vault_secret" "username" {
  name         = var.client_id
  value        = var.username_value
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [module.key_vault.rbac_role_id]
}

resource "azurerm_key_vault_secret" "password" {
  name         = var.client_id
  value        = var.password_value
  key_vault_id = module.key_vault.key_vault_id
  depends_on = [module.key_vault.rbac_role_id]
}

/*-----------------------------------------------------
Azure Event Hub
-----------------------------------------------------*/
module "event_hub_namespace" {
  source              = "./../modules/event-hub-namespace"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  project             = var.project
}

module "event_hub_metsa" {
  source              = "./../modules/event-hub"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  project             = var.project
  namespace_name      = module.event_hub_namespace.name
  message_name        = "metsa"
}

/*-----------------------------------------------------
Azure Data Explorer Cluster
-----------------------------------------------------*/
module "data_explorer_cluster" {
  source              = "./../modules/data-explorer-cluster"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  project             = var.project

}

/*-----------------------------------------------------
Azure Data Explorer Database
-----------------------------------------------------*/
module "data_explorer_database" {
  source              = "./../modules/data-explorer-database"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  project             = var.project
  dx_cluster_name     = module.data_explorer_cluster.data_explorer_cluster_name
}

/*-----------------------------------------------------
Azure Data Explorer Database Create Table
-----------------------------------------------------*/
module "data_explorer_create_table" {
  source      = "./../modules/data-explorer-kustoscript"
  database_id = module.data_explorer_database.data_explorer_database_id
}

/*-----------------------------------------------------
Azure Data Explorer event hub connector
-----------------------------------------------------*/

# Create an Event Hub connector and a raw table for the payload data.
# Event Hubs related objects are created into this applications resource group
# ADX related objects are created into ADX's resource group.

module "data_explorer_event_hub_connector" {
  source                   = "./../modules/data-explorer-event-hub-connector"
  adx_resource_group_name  = data.azurerm_resource_group.rg_adx.name
  app_resource_group_name  = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg_adx.location
  environment              = var.environment
  project                  = var.project
  appname                  = var.appname
  event_hub_namespace_name = module.event_hub.event_hub_namespace_name
  event_hub_id             = module.event_hub.event_hub_id
  event_hub_name           = module.event_hub.event_hub_name
  dx_cluster_name          = data.azurerm_kusto_cluster.adx.name
  dx_database_name         = module.data_explorer_database.data_explorer_database_name
  dx_database_id           = module.data_explorer_database.data_explorer_database_id
}


/*-----------------------------------------------------
Storage
-----------------------------------------------------*/
module "storage" {
  source              = "./../modules/storage"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  project             = var.project
  create_blob         = true
}







