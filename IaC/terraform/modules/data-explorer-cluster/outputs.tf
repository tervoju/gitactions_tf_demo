output "data_explorer_cluster_id" {
  value = azurerm_kusto_cluster.dx_cluster.id
}

output "data_explorer_cluster_name" {
  value = azurerm_kusto_cluster.dx_cluster.name
}

output "data_explorer_cluster_uri" {
  value = azurerm_kusto_cluster.dx_cluster.uri
}
