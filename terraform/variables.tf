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
    environment = "prod"
    project     = "online-boutique"
    managed_by  = "terraform"
    owner       = "devops-team"
    cost_center = "TBD" 
    department  = "engineering"
    created_by  = "terraform"
    version     = "1.0.0"
  }
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
  type        = string
  default     = "acronlineboutique"
}

variable "acr_sku" {
  description = "The SKU of the Azure Container Registry"
  type        = string
  default     = "Standard"
}

variable "acr_admin_enabled" {
  description = "Enable admin user for Azure Container Registry"
  type        = bool
  default     = true
}

variable "aks_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "aks-online-boutique"
}

variable "aks_dns_prefix" {
  description = "The DNS prefix for the AKS cluster"
  type        = string
  default     = "online-boutique"
}

variable "aks_node_count" {
  description = "The number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "aks_vm_size" {
  description = "The size of the VM for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "aks_os_disk_size_gb" {
  description = "The size of the OS disk for AKS nodes in GB"
  type        = number
  default     = 30
}

variable "aks_enable_auto_scaling" {
  description = "Enable auto scaling for the AKS cluster"
  type        = bool
  default     = true
}

variable "aks_min_count" {
  description = "Minimum number of nodes for auto scaling"
  type        = number
  default     = 1
}

variable "aks_max_count" {
  description = "Maximum number of nodes for auto scaling"
  type        = number
  default     = 3
}

variable "aks_network_plugin" {
  description = "Network plugin to use for AKS"
  type        = string
  default     = "kubenet"
}

variable "aks_network_policy" {
  description = "Network policy to use for AKS"
  type        = string
  default     = "calico"
}
