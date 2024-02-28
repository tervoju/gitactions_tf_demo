resource "azurerm_storage_account" "storage" {
  name                     = substr(replace("fz${var.appname}${var.project}${var.environment}", "/[^0-9a-z]/", ""), 0, 24)
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
  }
}


resource "azurerm_service_plan" "plan" {
  name                = "serviceplan-${var.appname}${var.project}${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"

  tags = {
    environment = var.environment
  }
}


resource "azurerm_application_insights" "insights" {
  name                = "appinsights-${var.appname}${var.project}${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"

  tags = {
    environment = var.environment
  }
}


resource "azurerm_linux_function_app" "funapp" {
  name                = "funapp-${var.appname}${var.project}${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  app_settings = var.app_settings

  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  service_plan_id            = azurerm_service_plan.plan.id

  site_config {
    application_insights_connection_string = azurerm_application_insights.insights.connection_string
    application_insights_key               = azurerm_application_insights.insights.instrumentation_key

    dynamic "ip_restriction" {
      for_each = var.allowed_ip_blocks_list
      content {
        action     = "Allow"
        ip_address = ip_restriction.value
      }
    }

    application_stack {
      python_version = var.python_version
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = var.environment
  }

  # These change when App is published and Terraform thinks it needs to set them null 
  # We want to ignore those
  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_ENABLE_SYNC_UPDATE_SITE"],
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }
}