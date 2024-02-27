# Create an Azure Data Factory
resource "azurerm_data_factory" "adf" {
  name                = "df-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  identity {
    type = "SystemAssigned"
  }
}

locals {
  dataFile = "mock-data.csv"
}

/*
Create data to read from blob storage
*/
resource "azurerm_storage_blob" "adf_data" {
  name                   = local.dataFile
  storage_account_name   = var.st_account_name
  storage_container_name = var.st_container_name
  type                   = "Block"
  access_tier            = "Hot"
  source                 = "./files/${local.dataFile}"
}

/*
Links to Azure storage and data explorer
*/
resource "azurerm_data_factory_linked_service_azure_blob_storage" "adf_connection" {
  name              = "blob-ln-${azurerm_data_factory.adf.name}"
  data_factory_id   = azurerm_data_factory.adf.id
  connection_string = var.st_connection_string
}

resource "azurerm_data_factory_dataset_delimited_text" "data_source" {
  name                = "csv_source"
  data_factory_id     = azurerm_data_factory.adf.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.adf_connection.name


  azure_blob_storage_location {
    container = var.st_container_name
    filename  = local.dataFile
  }

  # encoding            = "UTF-8"
  # column_delimiter = ","
  # row_delimiter       = "\r\n"
  first_row_as_header = true
  null_value          = "NULL"
}

resource "azurerm_data_factory_linked_service_kusto" "kusto_connection" {
  name                 = "dec-ln-${azurerm_data_factory.adf.name}"
  data_factory_id      = azurerm_data_factory.adf.id
  kusto_endpoint       = var.dx_cluster_uri
  kusto_database_name  = var.dx_database_name
  use_managed_identity = true
}

resource "azurerm_kusto_database_principal_assignment" "kusto_connection" {
  name                = "dedb-mi-${azurerm_data_factory.adf.name}"
  resource_group_name = var.resource_group_name
  cluster_name        = var.dx_cluster_name
  database_name       = var.dx_database_name

  tenant_id      = azurerm_data_factory.adf.identity.0.tenant_id
  principal_id   = azurerm_data_factory.adf.identity.0.principal_id
  principal_type = "App"
  role           = "Ingestor"

  depends_on = [
    azurerm_data_factory.adf
  ]
}

resource "azurerm_data_factory_custom_dataset" "data_sink" {
  name            = "kusto_sink"
  data_factory_id = azurerm_data_factory.adf.id
  type            = "AzureDataExplorerTable"

  linked_service {
    name = azurerm_data_factory_linked_service_kusto.kusto_connection.name
  }

  type_properties_json = <<JSON
{
  "table": "generic_table"
}
JSON

  schema_json = <<JSON
[{
  "type": "dynamic",
  "name": "payload"
}]
JSON
}

resource "azurerm_data_factory_pipeline" "data_pipeline" {
  name            = "static_data_pipeline"
  data_factory_id = azurerm_data_factory.adf.id

  activities_json = <<JSON
[
  {
      "name": "Copy data1",
      "type": "Copy",
      "dependsOn": [],
      "policy": {
          "timeout": "0.12:00:00",
          "retry": 0,
          "retryIntervalInSeconds": 30,
          "secureOutput": false,
          "secureInput": false
      },
      "userProperties": [],
      "typeProperties": {
          "source": {
              "type": "DelimitedTextSource",
              "storeSettings": { "type": "AzureBlobStorageReadSettings", "recursive": true, "enablePartitionDiscovery": false },
              "formatSettings": { "type": "DelimitedTextReadSettings" }
          },
          "sink": {
              "type": "AzureDataExplorerSink"
          },
          "enableStaging": false,
          "translator": {
              "type": "TabularTranslator",
              "mappings": [
                  {
                      "source": { "name": "value" },
                      "sink": { "name": "payload", "physicalType": "dynamic" }
                  }
              ],
              "typeConversion": true,
              "typeConversionSettings": { "allowDataTruncation": true, "treatBooleanAsNumber": false }
          }
      },
      "inputs": [
          {
              "referenceName": "${azurerm_data_factory_dataset_delimited_text.data_source.name}",
              "type": "DatasetReference"
          }
      ],
      "outputs": [
          {
              "referenceName": "${azurerm_data_factory_custom_dataset.data_sink.name}",
              "type": "DatasetReference"
          }
      ]
  }
]
JSON
}

resource "azurerm_data_factory_trigger_blob_event" "data_trigger" {
  name               = "static_data_change_trigger"
  data_factory_id    = azurerm_data_factory.adf.id
  storage_account_id = var.st_account_id

  events                = ["Microsoft.Storage.BlobCreated"]
  blob_path_begins_with = "/${var.st_container_name}/blobs/"
  blob_path_ends_with   = ".csv"
  ignore_empty_blobs    = true

  pipeline {
    name = azurerm_data_factory_pipeline.data_pipeline.name
  }
}
