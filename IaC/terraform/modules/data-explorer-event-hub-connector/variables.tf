// Base variables
variable "adx_resource_group_name" {
  type        = string
  description = "The resource group that contains the ADX Cluster and other ADX related entities"
}

variable "app_resource_group_name" {
  type        = string
  description = "The resource group that contains the App or Service that produces the data"
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "appname" {
  type = string
}

// Event Hub
variable "event_hub_namespace_name" {
  type = string
}

variable "event_hub_id" {
  type = string
}

variable "event_hub_name" {
  type = string
}

// Data Explorer
variable "dx_cluster_name" {
  type = string
}

variable "dx_database_name" {
  type = string
}

variable "dx_database_id" {
  type = string
}
