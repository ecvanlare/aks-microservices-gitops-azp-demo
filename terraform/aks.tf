resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.rg_online_boutique.location
  resource_group_name = azurerm_resource_group.rg_online_boutique.name
  dns_prefix          = var.aks_dns_prefix

  default_node_pool {
    name                = "default"
    node_count          = var.aks_node_count
    vm_size             = var.aks_vm_size
    os_disk_size_gb     = var.aks_os_disk_size_gb
    enable_auto_scaling = var.aks_enable_auto_scaling
    min_count           = var.aks_min_count
    max_count           = var.aks_max_count
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = var.aks_network_plugin
    network_policy     = var.aks_network_policy
    load_balancer_sku  = "standard"
  }

  tags = var.tags
}

# Output the AKS cluster credentials
output "aks_kube_config" {
  description = "The kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
} 