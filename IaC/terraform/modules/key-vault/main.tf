# Create Azure key vault
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "iot_keys" {
  name                            = replace("kva${var.project}${var.environment}", "-", "")
  resource_group_name             = var.resource_group_name
  location                        = var.location
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 7
  sku_name                        = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions         = ["Create", "Get", "List", "Purge", "Recover", ]
    secret_permissions      = ["Get", "List", "Purge", "Recover", "Set"]
    certificate_permissions = ["Create", "Get", "List", "Purge", "Recover", "Update"]
    storage_permissions     = ["Get"]
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}
