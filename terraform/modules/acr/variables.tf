variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the ACR"
  type        = string
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "acr_sku" {
  description = "SKU of the Azure Container Registry"
  type        = string
  default     = "Standard"
}

variable "acr_admin_enabled" {
  description = "Enable admin user for the Azure Container Registry"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to be applied to the ACR"
  type        = map(string)
  default     = {}
} 