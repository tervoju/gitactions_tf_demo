resource "azurerm_storage_account" "storage" {
  name                     = replace("funcst${var.project}${var.environment}", "/[^0-9a-z]/", "")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
  }
}


resource "azurerm_service_plan" "plan" {
  name                = "serviceplan-${var.project}${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"

  tags = {
    environment = var.environment
  }
}


resource "azurerm_application_insights" "insights" {
  name                = "appinsights-${var.project}${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"

  tags = {
    environment = var.environment
  }
}
