/*-----------------------------------------------------
Terraform init
-----------------------------------------------------*/
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.93.0"
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
  project             = var.project
  appname             = var.appname
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  python_version      = "3.11"
  app_settings = {
    KEYVAULT_NAME            = module.key_vault.key_vault_name
    KEY_VAULT_URL            = "https://${module.key_vault.key_vault_name}.vault.azure.net/"
    EVENT_HUB_NAMESPACE_NAME = module.event_hub.event_hub_namespace_name
    EVENT_HUB_NAMESPACE_FQDN = "${module.event_hub.event_hub_namespace_name}.servicebus.windows.net"
    EVENT_HUB_NAME           = module.event_hub.event_hub_name
  }
}

/*----------------------------------------------------------------
KEY VAULT 
----------------------------------------------------------------*/
module "key_vault" {
  source              = "./../modules/key-vault"
  project             = var.project
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  #appname             = var.appname
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
module "event_hub" {
  source              = "./../modules/event-hub"
  project             = var.project
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  appname             = var.appname
}

# Allow the Function App to send event data to the Event Hub
resource "azurerm_role_assignment" "data_sender" {
  scope                = module.event_hub.event_hub_namespace_id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = module.function_app.principal_id
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
  project             = var.project
  source              = "./../modules/data-explorer-database"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  appname             = var.appname
  dx_cluster_name     = module.data_explorer_cluster.data_explorer_cluster_name
}

# Give the DevOps Service Connection (Service Principal) the privileges
# to administrate the databases. Needed for various operations such as 
# setting: .alter-merge cluster policy managed_identity
resource "azurerm_kusto_cluster_principal_assignment" "example" {
  name                = "ADXServicePrincipalAssignment"
  resource_group_name = var.resource_group_name
  cluster_name        = module.data_explorer_cluster.data_explorer_cluster_name
  tenant_id      = var.tenant_id
  principal_id   = var.sp_client_id
  principal_type = "App"
  role           = "AllDatabasesAdmin"
}


/*-----------------------------------------------------
Azure Data Explorer event hub connector
-----------------------------------------------------*/
# Create an Event Hub connector and a raw table for the payload data.
# Event Hubs related objects are created into this applications resource group
# ADX related objects are created into ADX's resource group.

module "data_explorer_event_hub_connector" {
  source                   = "./../modules/data-explorer-event-hub-connector"
  project                  = var.project
  location                 = var.location
  environment              = var.environment
  appname                  = var.appname
  resource_group_name      = var.resource_group_name
  adx_resource_group_name  = var.resource_group_name
  app_resource_group_name  = var.resource_group_name
  event_hub_namespace_name = module.event_hub.event_hub_namespace_name
  event_hub_id             = module.event_hub.event_hub_id
  event_hub_name           = module.event_hub.event_hub_name
  dx_cluster_name          = module.data_explorer_cluster.data_explorer_cluster_name
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







