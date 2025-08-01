output "kube_config_raw" {
  description = "The raw kube config for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_identity" {
  description = "The identity block of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.identity
}

output "cluster_principal_id" {
  description = "The principal ID of the AKS cluster's system-assigned managed identity"
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

output "kubelet_identity_object_id" {
  description = "The object ID of the kubelet identity"
  value       = var.kubelet_identity_object_id
}

output "aad_rbac_enabled" {
  description = "Whether Azure AD RBAC is enabled on the cluster"
  value       = length(azurerm_kubernetes_cluster.aks.azure_active_directory_role_based_access_control) > 0
}

output "admin_group_object_ids" {
  description = "The admin group object IDs configured for AAD RBAC"
  value       = azurerm_kubernetes_cluster.aks.azure_active_directory_role_based_access_control[0].admin_group_object_ids
}

output "azure_rbac_enabled" {
  description = "Whether Azure RBAC is enabled for Kubernetes authorization"
  value       = azurerm_kubernetes_cluster.aks.azure_active_directory_role_based_access_control[0].azure_rbac_enabled
} 