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