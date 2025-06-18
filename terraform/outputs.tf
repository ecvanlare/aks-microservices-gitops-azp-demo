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
  value       = module.aks_subnet.subnet_id
}

output "appgw_subnet_id" {
  description = "The ID of the App Gateway subnet"
  value       = module.appgw_subnet.subnet_id
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

output "acr_push_identity_principal_id" {
  description = "The principal ID of the user-assigned managed identity for ACR push"
  value       = azurerm_user_assigned_identity.acr_push.principal_id
}

output "aks_identity_principal_id" {
  description = "The principal ID of the AKS cluster's system-assigned managed identity"
  value       = module.aks.cluster_principal_id
} 