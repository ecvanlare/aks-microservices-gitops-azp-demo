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

output "kubelet_identity" {
  description = "The kubelet identity used by the AKS cluster"
  value       = azurerm_user_assigned_identity.kubelet
}

output "system_assigned_identity_principal_id" {
  description = "The principal ID of the system-assigned identity"
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
} 