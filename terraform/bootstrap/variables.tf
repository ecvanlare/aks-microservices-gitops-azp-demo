variable "resource_group_name" {
  description = "The name of the resource group for the Online Boutique infrastructure"
  type        = string
  default     = "rg-online-boutique-bootstrap"
}

variable "resource_group_location" {
  description = "The Azure region where the resource group will be created"
  type        = string
  default     = "uksouth" # UK South region
}

variable "storage_account_name" {
  description = "The name of the storage account used to store Terraform state"
  type        = string
  default     = "stonlineboutiquebootstf"
}

variable "storage_container_name" {
  description = "The name of the storage container used to store Terraform state"
  type        = string
  default     = "tfstate"
}

variable "storage_container_access_type" {
  description = "The access type for the storage container"
  type        = string
  default     = "private"
}

variable "storage_blob_versioning_enabled" {
  description = "Enable blob versioning for enhanced data protection"
  type        = bool
  default     = true
}

variable "storage_soft_delete_retention_days" {
  description = "Number of days to retain deleted blobs for soft delete protection"
  type        = number
  default     = 7
  validation {
    condition     = var.storage_soft_delete_retention_days >= 1 && var.storage_soft_delete_retention_days <= 365
    error_message = "Soft delete retention days must be between 1 and 365."
  }
}

variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    environment = "bootstrap"
    project     = "online-boutique"
    managed_by  = "terraform"
  }
}

variable "resource_group_tags" {
  description = "Additional tags specific to the resource group"
  type        = map(string)
  default = {
    purpose = "bootstrap"
  }
}

variable "storage_account_tags" {
  description = "Additional tags specific to the storage account"
  type        = map(string)
  default = {
    purpose = "terraform-state"
  }
}