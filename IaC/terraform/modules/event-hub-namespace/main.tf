resource "azurerm_eventhub_namespace" "namespace" {
  name                = "hub-ns-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  capacity            = 1

  tags = {
    environment = var.environment
  }
}
