variable "resource_group_name" {
  description = "Resource group which will contain demo resources"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "network_address_space" {
  description = "List of CIDR blocks which define the address space for the iot network"
  default     = ["10.0.0.0/16"]
  type        = list(string)
  /*
  validation {
    condition = alltrue([
      // Attempt to ensure the network address range is in CIDR format.
      // This does not properly validate the octets in the CIDR block.
      for address_space in var.network_address_space:
        can(regex(
          "\\d{1,3}\\.{1}\\d{1,3}\\.{1}\\d{1,3}\\.{1}\\d{1,3}\\/{1}\\d{1,2}",
          var.network_address_space, 
        ))
    ])
    error_message = "Invalid virtual network address space"
  }
  */
}
