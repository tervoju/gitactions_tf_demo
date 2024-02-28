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

variable "appname" {
  type = string
}

variable "app_settings" {
  type        = map(string)
  description = "Map of Application Settings. Function can access these as environment variables."
  default     = {}
}

variable "python_version" {
  type        = string
  description = "Python version used. Example: 3.10"
}

variable "allowed_ip_blocks_list" {
  type        = list(string)
  description = "List of allowed IP address blocks in CIRD format. Example: 192.168.0.1/32"
  default     = []
}

