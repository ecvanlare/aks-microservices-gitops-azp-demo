variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "aks_managed_identity_object_id" {
  description = "Object ID of AKS managed identity"
  type        = string
}

variable "enable_rbac_authorization" {
  description = "Enable Azure RBAC authorization instead of access policies"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 