variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the AKS cluster"
  type        = string
}

variable "name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "node_pool" {
  description = "Node pool configuration"
  type = object({
    node_count         = number
    vm_size            = string
    os_disk_size_gb    = number
    enable_auto_scaling = bool
    min_count          = optional(number)
    max_count          = optional(number)
  })
}

variable "network" {
  description = "Network configuration"
  type = object({
    plugin          = string
    policy          = string
    subnet_id       = string
    service_cidr    = string
    dns_service_ip  = string
  })
}

variable "kubelet_identity_name" {
  description = "Name of the user-assigned identity for AKS kubelet"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the AKS cluster"
  type        = map(string)
  default     = {}
} 