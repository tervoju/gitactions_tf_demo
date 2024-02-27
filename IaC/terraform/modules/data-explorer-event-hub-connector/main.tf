resource "azurerm_eventhub_consumer_group" "dx_group" {
  name                = "cg-eh-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  namespace_name      = var.event_hub_namespace_name
  eventhub_name       = var.event_hub_name
}

// Requires provider hashicorp/azurerm v3.50.0 to work
resource "azurerm_kusto_eventhub_data_connection" "dx_connection" {
  name                = "eh-de-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  cluster_name        = var.dx_cluster_name
  database_name       = var.dx_database_name

  eventhub_id    = var.event_hub_id
  consumer_group = azurerm_eventhub_consumer_group.dx_group.name

  table_name        = var.dx_table_name
  mapping_rule_name = var.dx_mapping_name
  data_format       = "JSON"
}
