resource "azurerm_dashboard_grafana" "dashboard" {
  name                              = replace("graf${var.project}${var.environment}", "/[^0-9a-z]/", "")
  resource_group_name               = var.resource_group_name
  location                          = var.location
  api_key_enabled                   = false
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kusto_database_principal_assignment" "dashboard" {
  name                = "GrafanaKustoPrincipalAssignment"
  resource_group_name = var.resource_group_name
  cluster_name        = var.data_explorer_cluster_name
  database_name       = var.data_explorer_database_name

  tenant_id      = azurerm_dashboard_grafana.dashboard.identity[0].tenant_id
  principal_id   = azurerm_dashboard_grafana.dashboard.identity[0].principal_id
  principal_type = "App"
  role           = "Viewer"
}
