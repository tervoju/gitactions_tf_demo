resource "azurerm_storage_account" "storage" {
  name                     = replace("st${var.project}${var.environment}", "/[^0-9a-z]/", "")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_storage_container" "storage" {
  count                 = var.create_blob ? 1 : 0
  name                  = "blob-${var.project}-${var.environment}"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}
