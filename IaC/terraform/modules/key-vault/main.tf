resource "azurerm_key_vault" "vault" {
  name                            = replace("kva${var.appname}${var.project}dev", "-", "")
  resource_group_name             = var.resource_group_name
  location                        = var.location
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 7
  sku_name                        = "standard"

  enable_rbac_authorization = true

  tags = {
    environment = var.environment
  }
}

# Allow the Service Principal we are using for Terraform deployment to add secrets
resource "azurerm_role_assignment" "officer" {
  scope                = azurerm_key_vault.vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
