resource "azurerm_eventhub_namespace" "iot" {
  name                = "ns-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  capacity            = 1

  tags = {
    environment = var.environment
  }
}

// Messages from edge
resource "azurerm_eventhub" "iot_k8s" {
  name                = "eh-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_eventhub_namespace.iot.name
  partition_count     = 2
  message_retention   = 1
}

// Publish messages from edge
resource "azurerm_eventhub_authorization_rule" "iot_k8s" {
  name                = "pub-eh-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_eventhub_namespace.iot.name
  eventhub_name       = azurerm_eventhub.iot_k8s.name
  listen              = false
  send                = true
  manage              = false
}

// Subscribe to edge messages from digital twin
resource "azurerm_eventhub_authorization_rule" "ua_twin" {
  name                = "sub-eh-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_eventhub_namespace.iot.name
  eventhub_name       = azurerm_eventhub.iot_k8s.name

  listen = true
  send   = false
  manage = false
}

// History messages from digital twin
resource "azurerm_eventhub" "digital_twin" {
  name                = "twin-eh-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_eventhub_namespace.iot.name
  partition_count     = 2
  message_retention   = 1
}

// Publish history messages from digital twin
resource "azurerm_eventhub_authorization_rule" "digital_twin" {
  name                = "pub-twin-eh-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_eventhub_namespace.iot.name
  eventhub_name       = azurerm_eventhub.digital_twin.name

  listen = true
  send   = true
  manage = false
}
