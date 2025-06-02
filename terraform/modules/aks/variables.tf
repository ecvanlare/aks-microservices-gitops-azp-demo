variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the AKS cluster"
  type        = string
}

variable "aks_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "aks_dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "aks_node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "aks_vm_size" {
  description = "Size of the VM for the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "aks_os_disk_size_gb" {
  description = "OS disk size in GB for the default node pool"
  type        = number
  default     = 30
}

variable "aks_enable_auto_scaling" {
  description = "Enable auto scaling for the default node pool"
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
  description = "Network plugin for the AKS cluster"
  type        = string
  default     = "azure"
}

variable "aks_network_policy" {
  description = "Network policy for the AKS cluster"
  type        = string
  default     = "azure"
}

variable "subnet_id" {
  description = "ID of the subnet where the AKS cluster will be deployed"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the AKS cluster"
  type        = map(string)
  default     = {}
} 