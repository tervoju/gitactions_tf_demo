# Namespace
resource "azurerm_eventhub_namespace" "ns" {
  name                = "ns-${var.appname}-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  capacity            = 1

  tags = {
    environment = var.environment
  }
}

# Hub
resource "azurerm_eventhub" "hub" {
  name                = "eh-${var.appname}-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_eventhub_namespace.ns.name
  partition_count     = 2 # Cannot be changed unless sku is Premium
  message_retention   = var.message_retention_days
}
