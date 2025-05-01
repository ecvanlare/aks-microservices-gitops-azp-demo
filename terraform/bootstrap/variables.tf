variable "resource_group_name" {
  description = "The name of the bootstrap resource group"
  type        = string
  default     = "rg-online-boutique-bootstrap"
}

variable "resource_group_location" {
  description = "The Azure region where the bootstrap resources will be created"
  type        = string
  default     = "uksouth"  # London region
}

variable "storage_account_name" {
  description = "The name of the storage account for Terraform state"
  type        = string
  default     = "stonlineboutiquebootstf"
}

variable "storage_container_name" {
  description = "The name of the storage container for Terraform state"
  type        = string
  default     = "online-boutique-bootstrap-tfstate"
} 