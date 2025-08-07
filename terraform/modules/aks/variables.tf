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
}

# Node Pool Configuration
variable "node_pool" {
  description = "Node pool configuration"
  type = object({
    name                 = string
    vm_size              = string
    os_disk_size_gb      = number
    min_count            = number
    max_count            = number
    max_pods             = number
    node_labels          = map(string)
    auto_scaling_enabled = bool
  })
}

# Network Configuration
variable "network" {
  description = "Network configuration"
  type = object({
    plugin            = string
    policy            = string
    private_subnet_id = string
    public_subnet_id  = string
    service_cidr      = string
    dns_service_ip    = string
  })
}

# Identity Configuration
variable "cluster_identity_id" {
  description = "The ID of the user-assigned identity for the cluster"
  type        = string
}

variable "kubelet_identity_id" {
  description = "The ID of the user-assigned identity for the kubelet"
  type        = string
}

variable "kubelet_identity_client_id" {
  description = "The client ID of the user-assigned identity for the kubelet"
  type        = string
}

variable "kubelet_identity_object_id" {
  description = "The object ID of the user-assigned identity for the kubelet"
  type        = string
}

# Load Balancer Configuration
variable "load_balancer_sku" {
  description = "The SKU of the load balancer"
  type        = string
}

variable "outbound_type" {
  description = "The outbound type for the cluster"
  type        = string
}

# RBAC Configuration
variable "aad_rbac" {
  description = "Azure Active Directory RBAC configuration"
  type = object({
    admin_group_object_ids = list(string)
    azure_rbac_enabled     = bool
    user_groups = list(object({
      name      = string
      object_id = string
      roles     = list(string)
    }))
  })
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "user_node_pool" {
  description = "The user node pool configuration"
  type = object({
    name                 = string
    vm_size              = string
    os_disk_size_gb      = number
    min_count            = number
    max_count            = number
    max_pods             = number
    node_taints          = list(string)
    node_labels          = map(string)
    auto_scaling_enabled = bool
  })
}

variable "ingress_node_pool" {
  description = "The ingress node pool configuration"
  type = object({
    name                 = string
    vm_size              = string
    os_disk_size_gb      = number
    min_count            = number
    max_count            = number
    max_pods             = number
    node_taints          = list(string)
    node_labels          = map(string)
    auto_scaling_enabled = bool
  })
}

# Cluster Autoscaler Configuration
variable "enable_cluster_autoscaler" {
  description = "Whether to enable cluster autoscaler"
  type        = bool
}

variable "autoscaler_profile" {
  description = "Cluster autoscaler profile configuration (scale-down settings)"
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