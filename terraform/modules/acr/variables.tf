variable "name" {
  description = "The name of the container registry"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the container registry"
  type        = string
}

variable "sku" {
  description = "SKU of the container registry"
  type        = string
  default     = "Basic"
}

variable "admin_enabled" {
  description = "Enable admin access to the container registry"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
} 