locals {
  table_name   = "opcua_raw"
  mapping_name = "${local.table_name}_mapping"
}

resource "azurerm_kusto_script" "create_opcua_table" {
  name                               = "create_${local.table_name}"
  database_id                        = var.database_id
  script_content                     = ".create table ${local.table_name}(payload: dynamic)"
  continue_on_errors_enabled         = true
  force_an_update_when_value_changed = "first"
}

resource "azurerm_kusto_script" "create_opcua_ingestion_table" {
  name                               = "create_${local.mapping_name}"
  database_id                        = var.database_id
  script_content                     = ".create table ${local.table_name} ingestion json mapping '${local.mapping_name}' @'[{\"column\":\"payload\",\"path\":\"$\",\"datatype\":\"dynamic\"}]'"
  continue_on_errors_enabled         = true
  force_an_update_when_value_changed = "first"
  depends_on = [
    azurerm_kusto_script.create_opcua_table
  ]
}

resource "azurerm_kusto_script" "create_opcua_history_table" {
  name                               = "create_${local.table_name}_history"
  database_id                        = var.database_id
  script_content                     = ".create table ${local.table_name}_history(payload: dynamic)"
  continue_on_errors_enabled         = true
  force_an_update_when_value_changed = "first"
}

resource "azurerm_kusto_script" "create_opcua_history_ingestion_table" {
  name                               = "create_${local.mapping_name}_history"
  database_id                        = var.database_id
  script_content                     = ".create table ${local.table_name} ingestion json mapping '${local.mapping_name}_history' @'[{\"column\":\"payload\",\"path\":\"$\",\"datatype\":\"dynamic\"}]'"
  continue_on_errors_enabled         = true
  force_an_update_when_value_changed = "first"
  depends_on = [
    azurerm_kusto_script.create_opcua_history_table
  ]
}
