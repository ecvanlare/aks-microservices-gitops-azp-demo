# Resource Group Outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = module.resource_group.resource_group_location
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = module.resource_group.resource_group_id
}

# Network Outputs
output "vnet_name" {
  description = "The name of the virtual network"
  value       = module.vnet.vnet_name
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = module.vnet.vnet_id
}

output "aks_subnet_id" {
  description = "The ID of the AKS subnet"
  value       = module.subnets["aks-cluster"].subnet_id
}



output "nsg_id" {
  description = "The ID of the network security group"
  value       = module.nsg.nsg_id
}

# AKS Outputs
output "aks_name" {
  description = "The name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "aks_id" {
  description = "The ID of the AKS cluster"
  value       = module.aks.cluster_id
}

output "aks_kube_config" {
  description = "The kubeconfig for the AKS cluster"
  value       = module.aks.kube_config_raw
  sensitive   = true
}

# AAD RBAC Outputs
output "aad_rbac_enabled" {
  description = "Whether Azure AD RBAC is enabled on the cluster"
  value       = module.aks.aad_rbac_enabled
}

output "admin_group_object_ids" {
  description = "The admin group object IDs configured for AAD RBAC"
  value       = module.aks.admin_group_object_ids
}

output "azure_rbac_enabled" {
  description = "Whether Azure RBAC is enabled for Kubernetes authorization"
  value       = module.aks.azure_rbac_enabled
}

output "user_groups" {
  description = "The user groups configured for AAD RBAC"
  value = [
    {
      name      = var.admin_group_name
      object_id = azuread_group.aks_groups["admins"].object_id
      role      = var.admin_role
    },
    {
      name      = var.developer_group_name
      object_id = azuread_group.aks_groups["developers"].object_id
      role      = var.developer_role
    },
    {
      name      = var.viewer_group_name
      object_id = azuread_group.aks_groups["viewers"].object_id
      role      = var.viewer_role
    }
  ]
}

output "user_group_role_assignments" {
  description = "The role assignments for user groups"
  value       = values(module.user_group_roles)[*].id
}

# ACR Outputs
output "acr_name" {
  description = "The name of the container registry"
  value       = module.acr.acr_name
}

output "acr_login_server" {
  description = "The login server of the container registry"
  value       = module.acr.acr_login_server
}

output "acr_id" {
  description = "The ID of the container registry"
  value       = module.acr.acr_id
}

output "aks_acr_pull_role_id" {
  description = "The ID of the AcrPull role assignment for AKS"
  value       = module.aks_acr_pull.id
}

output "acr_push_role_id" {
  description = "The ID of the AcrPush role assignment"
  value       = module.acr_push.id
}

output "aks_network_contributor_role_id" {
  description = "The ID of the Network Contributor role assignment for AKS"
  value       = module.aks_network_contributor.id
}

output "acr_push_identity_principal_id" {
  description = "The principal ID of the user-assigned managed identity for ACR push"
  value       = azurerm_user_assigned_identity.identities["acr_push"].principal_id
}

output "aks_identity_principal_id" {
  description = "The principal ID of the AKS cluster's system-assigned managed identity"
  value       = module.aks.cluster_principal_id
}

# Managed Identity Outputs
output "managed_identities" {
  description = "The managed identities created for AKS"
  value = {
    cluster = {
      name         = azurerm_user_assigned_identity.identities["cluster"].name
      id           = azurerm_user_assigned_identity.identities["cluster"].id
      principal_id = azurerm_user_assigned_identity.identities["cluster"].principal_id
      client_id    = azurerm_user_assigned_identity.identities["cluster"].client_id
    }
    kubelet = {
      name         = azurerm_user_assigned_identity.identities["kubelet"].name
      id           = azurerm_user_assigned_identity.identities["kubelet"].id
      principal_id = azurerm_user_assigned_identity.identities["kubelet"].principal_id
      client_id    = azurerm_user_assigned_identity.identities["kubelet"].client_id
    }
    acr_push = {
      name         = azurerm_user_assigned_identity.identities["acr_push"].name
      id           = azurerm_user_assigned_identity.identities["acr_push"].id
      principal_id = azurerm_user_assigned_identity.identities["acr_push"].principal_id
      client_id    = azurerm_user_assigned_identity.identities["acr_push"].client_id
    }
  }
}



# Node Pool Outputs
output "ingress_node_pool_name" {
  description = "The name of the ingress node pool"
  value       = var.aks_ingress_node_pool.name
}

output "ingress_node_pool_vm_size" {
  description = "The VM size of the ingress node pool"
  value       = var.aks_ingress_node_pool.vm_size
}

# Network Security Group Outputs
output "nsg_rules" {
  description = "The network security group rules"
  value       = var.nsg_rules
}

# Node Pool Configuration Outputs
output "node_pools" {
  description = "The node pool configurations"
  value = {
    default = {
      name      = var.aks_node_pool.name
      vm_size   = var.aks_node_pool.vm_size
      min_count = var.aks_node_pool.min_count
      max_count = var.aks_node_pool.max_count
    }
    user = {
      name      = var.aks_user_node_pool.name
      vm_size   = var.aks_user_node_pool.vm_size
      min_count = var.aks_user_node_pool.min_count
      max_count = var.aks_user_node_pool.max_count
      max_pods  = var.aks_user_node_pool.max_pods
    }
    ingress = {
      name        = var.aks_ingress_node_pool.name
      vm_size     = var.aks_ingress_node_pool.vm_size
      min_count   = var.aks_ingress_node_pool.min_count
      max_count   = var.aks_ingress_node_pool.max_count
      max_pods    = var.aks_ingress_node_pool.max_pods
      node_taints = var.aks_ingress_node_pool.node_taints
      node_labels = var.aks_ingress_node_pool.node_labels
    }
  }
}

# Network Configuration Outputs
output "network_config" {
  description = "The network configuration for AKS"
  value = {
    plugin             = var.aks_network_plugin
    policy             = var.aks_network_policy
    service_cidr       = var.aks_service_cidr
    dns_service_ip     = var.aks_dns_service_ip
    vnet_name          = var.vnet_name
    vnet_address_space = var.vnet_address_space
  }
}

# Cluster Autoscaler Outputs
output "cluster_autoscaler" {
  description = "The cluster autoscaler configuration"
  value = {
    enabled = var.aks_enable_cluster_autoscaler
    profile = var.aks_autoscaler_profile
  }
} 