resource "azurerm_kusto_cluster" "dx_cluster" {
  name                = replace("d${var.project}${var.environment}", "-", "")
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Dev(No SLA)_Standard_E2a_v4"
    capacity = 1
  }

  tags = {
    Env = var.environment
  }
}
