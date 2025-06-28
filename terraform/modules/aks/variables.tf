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
    name                = string
    node_count          = number
    vm_size             = string
    os_disk_size_gb     = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
  })
}

variable "network" {
  description = "Network configuration"
  type = object({
    plugin         = string
    policy         = string
    subnet_id      = string
    service_cidr   = string
    dns_service_ip = string
  })
}

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

variable "load_balancer_sku" {
  description = "The SKU of the load balancer"
  type        = string
  default     = "standard"
}

variable "outbound_type" {
  description = "The outbound type for the cluster"
  type        = string
  default     = "loadBalancer"
}

variable "user_node_pool_name" {
  description = "The name of the user node pool"
  type        = string
  default     = "userpool"
}

variable "tags" {
  description = "Tags to be applied to the AKS cluster"
  type        = map(string)
  default     = {}
}

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
  default = {
    admin_group_object_ids = []
    azure_rbac_enabled     = true
    user_groups            = []
  }
} 