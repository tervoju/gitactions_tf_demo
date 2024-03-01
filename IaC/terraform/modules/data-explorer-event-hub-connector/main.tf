locals {
  # Raw data table
  table_name   = "${var.appname}_raw"
  mapping_name = "${local.table_name}_mapping"
}

resource "azurerm_eventhub_consumer_group" "dx_group" {
  name                = "cg-eh-${var.appname}-${var.project}-${var.environment}"
  resource_group_name = var.app_resource_group_name
  namespace_name      = var.event_hub_namespace_name
  eventhub_name       = var.event_hub_name
}

// Requires provider hashicorp/azurerm v3.50.0 to work
resource "azurerm_kusto_eventhub_data_connection" "dx_connection" {
  name                = "eh-de-${var.appname}-${var.project}-${var.environment}"
  resource_group_name = var.adx_resource_group_name
  location            = var.location
  cluster_name        = var.dx_cluster_name
  database_name       = var.dx_database_name

  eventhub_id    = var.event_hub_id
  consumer_group = azurerm_eventhub_consumer_group.dx_group.name

  table_name        = local.table_name
  mapping_rule_name = local.mapping_name
  data_format       = "JSON"

  depends_on = [azurerm_kusto_script.create_ingestion_mapping]
}

# Create raw table
resource "azurerm_kusto_script" "create_raw_table" {
  name                               = "create_${local.table_name}"
  database_id                        = var.dx_database_id
  script_content                     = ".create table ${local.table_name}(payload: dynamic)"
  continue_on_errors_enabled         = true
  force_an_update_when_value_changed = "first"
}

resource "azurerm_kusto_script" "create_ingestion_mapping" {
  name                               = "create_${local.mapping_name}"
  database_id                        = var.dx_database_id
  script_content                     = ".create table ${local.table_name} ingestion json mapping '${local.mapping_name}' @'[{\"column\":\"payload\",\"path\":\"$\",\"datatype\":\"dynamic\"}]'"
  continue_on_errors_enabled         = true
  force_an_update_when_value_changed = "first"
  depends_on = [
    azurerm_kusto_script.create_raw_table
  ]
}