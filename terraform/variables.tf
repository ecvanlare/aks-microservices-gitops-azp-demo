variable "resource_group_name" {
  description = "The name of the resource group for the Online Boutique project"
  type        = string
  default     = "rg-online-boutique"
}

variable "resource_group_location" {
  description = "The Azure region where the resource group will be created"
  type        = string
  default     = "uksouth"  # London region
}

variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    environment = "dev"
    project     = "online-boutique"
    managed_by  = "terraform"
    owner       = "devops-team"
    cost_center = "TBD" 
    department  = "engineering"
    created_by  = "terraform"
    version     = "1.0.0"
  }
}
