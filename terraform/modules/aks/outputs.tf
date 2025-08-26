output "kube_config_raw" {
  description = "The raw kube config for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.id
}

output "cluster_identity" {
  description = "The identity block of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.identity
}

output "cluster_principal_id" {
  description = "The principal ID of the AKS cluster's managed identity"
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

output "kubelet_identity_object_id" {
  description = "The object ID of the kubelet identity"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "aad_rbac_enabled" {
  description = "Whether Azure AD RBAC is enabled on the cluster"
  value       = length(var.admin_group_object_id) > 0
}

output "admin_group_object_ids" {
  description = "The admin group object IDs configured for AAD RBAC"
  value       = [var.admin_group_object_id]
}

output "azure_rbac_enabled" {
  description = "Whether Azure RBAC is enabled for Kubernetes authorization"
  value       = var.azure_rbac_enabled
}

output "additional_node_pools" {
  description = "Map of additional node pools created"
  value       = azurerm_kubernetes_cluster_node_pool.additional
}

output "network_profile" {
  description = "Network profile configuration"
  value       = azurerm_kubernetes_cluster.this.network_profile
} 