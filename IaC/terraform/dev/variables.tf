variable "base_tfstate" {
  type    = string
  default = "dev-tfstate"
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
  default = "dev"
}

variable "resource_group_name" {
  type    = string
  default = "RG-WEU-PPAD-MetrisDDWIiot-Dev-001"
}

variable "client_id_name" {
  type      = string
  default   = "client-id"
}

variable "client_id_value" {
  description = "Username for  API Oauth"
  sensitive   = true
  type        = string
}

variable "client_secret_name" {
  type      = string
  default = "client-secret-id"
}

variable "client_secret_value" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "sp_client_id" {
  type      = string
  sensitive = true
}

variable "appname" {
  type    = string
  default = "metsa"
}