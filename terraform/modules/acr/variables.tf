variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "name" {
  description = "Name of the container registry"
  type        = string
}

variable "sku" {
  description = "SKU of the container registry"
  type        = string
}

variable "admin_enabled" {
  description = "Enable admin access to the container registry"
  type        = bool
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
} 