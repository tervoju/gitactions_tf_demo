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

variable "message_retention_days" {
  type        = number
  default     = 1
  description = "How many days to keep the messages in the queue before expiring them."
}