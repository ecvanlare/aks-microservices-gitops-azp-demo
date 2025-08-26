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

variable "private_cluster_enabled" {
  description = "Whether to enable private cluster"
  type        = bool
  default     = true
}

# Default Node Pool Configuration
variable "default_node_pool" {
  description = "Default node pool configuration"
  type = object({
    name                 = string
    vm_size              = string
    os_disk_size_gb      = number
    min_count            = number
    max_count            = number
    max_pods             = number
    subnet_id            = string
    node_labels          = map(string)
    auto_scaling_enabled = bool
  })
}

# Network Profile Configuration
variable "network_profile" {
  description = "Network profile configuration"
  type = object({
    plugin            = string
    policy            = string
    service_cidr      = string
    dns_service_ip    = string
    load_balancer_sku = string
    outbound_type     = string
  })
}

# Identity Configuration
variable "cluster_identity_id" {
  description = "ID of the cluster managed identity"
  type        = string
}

# Kubelet Identity Configuration
variable "kubelet_identity" {
  description = "Kubelet identity configuration"
  type = object({
    user_assigned_identity_id = string
    client_id                 = string
    object_id                 = string
  })
}

# RBAC Configuration
variable "admin_group_object_id" {
  description = "Object ID of the admin group"
  type        = string
}

variable "azure_rbac_enabled" {
  description = "Whether Azure RBAC is enabled for Kubernetes authorization"
  type        = bool
  default     = true
}

# Cluster Autoscaler Configuration
variable "enable_cluster_autoscaler" {
  description = "Whether to enable cluster autoscaler"
  type        = bool
  default     = false
}

variable "autoscaler_profile" {
  description = "Cluster autoscaler profile configuration"
  type = object({
    scale_down_delay_after_add       = string
    scale_down_delay_after_delete    = string
    scale_down_delay_after_failure   = string
    scan_interval                    = string
    scale_down_unneeded              = string
    scale_down_unready               = string
    scale_down_utilization_threshold = string
  })
}

# Additional Node Pools
variable "additional_node_pools" {
  description = "Additional node pools configuration"
  type = map(object({
    name                 = string
    vm_size              = string
    os_disk_size_gb      = number
    min_count            = number
    max_count            = number
    max_pods             = number
    subnet_id            = string
    node_labels          = map(string)
    node_taints          = list(string)
    auto_scaling_enabled = bool
    tags                 = map(string)
  }))
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}