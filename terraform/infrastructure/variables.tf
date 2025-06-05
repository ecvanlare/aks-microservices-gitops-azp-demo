variable "resource_group_name" {
  description = "The name of the resource group for the Online Boutique infrastructure"
  type        = string
  default     = "rg-online-boutique-infra"
}

variable "resource_group_location" {
  description = "The Azure region where the resource group will be created"
  type        = string
  default     = "uksouth" # UK South region
}

variable "storage_account_name" {
  description = "The name of the storage account used to store Terraform state"
  type        = string
  default     = "stonlineboutiqueinfratf"
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

variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    environment = "infrastructure"
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