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
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention days for Key Vault"
  type        = number
}

variable "purge_protection_enabled" {
  description = "Enable purge protection for Key Vault"
  type        = bool
}

variable "sku_name" {
  description = "SKU name for Key Vault"
  type        = string
}

variable "network_acls" {
  description = "Network ACLs configuration for Key Vault"
  type = object({
    default_action = string
    bypass         = string
  })
}

variable "terraform_role_name" {
  description = "Azure RBAC role name for Terraform access to Key Vault"
  type        = string
}

variable "aks_role_name" {
  description = "Azure RBAC role name for AKS access to Key Vault"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
} 