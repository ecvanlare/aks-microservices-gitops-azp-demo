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
  description = "The cluster identity used by the AKS cluster"
  value = {
    id           = azurerm_kubernetes_cluster.aks.identity[0].id
    client_id    = azurerm_kubernetes_cluster.aks.identity[0].client_id
    principal_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  }
}

output "kubelet_identity" {
  description = "The kubelet identity used by the AKS cluster"
  value = {
    id           = azurerm_kubernetes_cluster.aks.kubelet_identity[0].id
    client_id    = azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
    principal_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].principal_id
  }
} 