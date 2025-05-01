variable "resource_group_name" {
  description = "The name of the resource group for the Online Boutique project"
  type        = string
  default     = "rg-online-boutique-bootstrap"
}

variable "resource_group_location" {
  description = "The Azure region where the resource group will be created"
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
    purpose = "infrastructure"
  }
}

variable "storage_account_tags" {
  description = "Additional tags specific to the storage account"
  type        = map(string)
  default = {
    purpose = "terraform-state"
  }
} 