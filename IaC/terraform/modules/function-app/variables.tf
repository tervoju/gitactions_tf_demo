variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "westeurope"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "neova-ddgm"
}

variable "environment" {
  description = "Current project environment"
  type        = string
  default     = "dev"
}

variable "parent_adx_managed_id" {
  type = map(string)
  default = {
    "dev"  = "3acf02e6-a6ef-4f8f-80b7-ccb2130277a6"
    "prod" = "not exists yet"
  }
}
