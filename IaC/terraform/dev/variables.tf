variable "base_tfstate" {
  type    = string
  default = "brightly-iot-tfstates"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "WEU"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "PPAD-MetrisDDWIiot"
}

variable "environment" {
  type    = string
  default = "Dev"
}

variable "baseresourcegroup" {
  type    = string
  default = "RG-WEU-PPAD-MetrisDDWIiot-Dev-001"
}

variable "resource_group_name" {
  type    = string
  default = "RG-WEU-PPAD-MetrisDDWIiot-Dev-001"
}

variable "client_id" {
  type      = string
  sensitive = true
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "function_app_name" {
  type    = string
  default = "funcapi2eventhub"
}