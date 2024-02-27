resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.network_address_space

  /* 
    We could create inline subnets here, but they are
    incompatible with standalone subnets which offer
    more flexibility on the long run by allowing e.g. 
    creation of new subnets for different components
    such as Databricks workspace and Data Factory.
  */
}

# NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Subnet
resource "azurerm_subnet" "private_subnet" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "private_subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  delegation {
    name = "private_delegation"
    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
      name = "Microsoft.Databricks/workspaces"
    }
  }
}

resource "azurerm_subnet" "public_subnet" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = "public_subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  delegation {
    name = "public_delegation"
    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
      name = "Microsoft.Databricks/workspaces"
    }
  }
}

# NSG association
resource "azurerm_subnet_network_security_group_association" "private_subnet_nsg" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = azurerm_subnet.private_subnet.id
}

resource "azurerm_subnet_network_security_group_association" "public_subnet_nsg" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = azurerm_subnet.public_subnet.id
}

# Output
output "network_id" {
  value = azurerm_virtual_network.vnet.id
}

output "network_address_space" {
  value = azurerm_virtual_network.vnet.address_space
}

output "private_subnet_name" {
  value = azurerm_subnet.private_subnet.name
}
output "public_subnet_name" {
  value = azurerm_subnet.public_subnet.name
}

output "private_subnet_association" {
  value = azurerm_subnet_network_security_group_association.private_subnet_nsg.id
}

output "public_subnet_association" {
  value = azurerm_subnet_network_security_group_association.public_subnet_nsg.id
}
