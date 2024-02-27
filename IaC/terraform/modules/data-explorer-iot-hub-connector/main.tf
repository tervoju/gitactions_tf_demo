resource "azurerm_iothub_consumer_group" "dx_group" {
  name                   = "cg-iot-${var.project}-${var.environment}"
  resource_group_name    = var.resource_group_name
  iothub_name            = var.iot_hub_name
  eventhub_endpoint_name = "events"
}

resource "azurerm_kusto_iothub_data_connection" "dx_connection" {
  name                = "iot-de-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  cluster_name        = var.dx_cluster_name
  database_name       = var.dx_database_name

  iothub_id                 = var.iot_hub_id
  consumer_group            = azurerm_iothub_consumer_group.dx_group.name
  shared_access_policy_name = var.iot_hub_shared_access_policy_name
  # event_system_properties   = []

  table_name        = var.dx_table_name
  mapping_rule_name = var.dx_mapping_name
  data_format       = "JSON"
}
