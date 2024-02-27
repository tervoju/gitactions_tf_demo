resource "azurerm_kusto_database" "database" {
  name                = "dedb-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  cluster_name        = var.dx_cluster_name

  hot_cache_period   = "P31D"
  soft_delete_period = "P365D"
}
