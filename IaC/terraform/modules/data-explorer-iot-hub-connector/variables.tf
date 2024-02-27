// Base variables
variable "resource_group_name" {
  type = string
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

// IoT Hub 
variable "iot_hub_id" {
  type = string
}

variable "iot_hub_name" {
  type = string
}

variable "iot_hub_shared_access_policy_name" {
  type = string
}

// Data Explorer
variable "dx_cluster_name" {
  type = string
}

variable "dx_database_name" {
  type = string
}

variable "dx_table_name" {
  type = string
}

variable "dx_mapping_name" {
  type = string
}
