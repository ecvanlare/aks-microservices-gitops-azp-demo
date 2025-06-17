resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name                = var.node_pool.name
    node_count          = var.node_pool.node_count
    vm_size             = var.node_pool.vm_size
    os_disk_size_gb     = var.node_pool.os_disk_size_gb
    enable_auto_scaling = var.node_pool.enable_auto_scaling
    min_count           = var.node_pool.min_count
    max_count           = var.node_pool.max_count
    vnet_subnet_id      = var.network.subnet_id
  }

  network_profile {
    network_plugin     = var.network.plugin
    network_policy     = var.network.policy
    service_cidr       = var.network.service_cidr
    dns_service_ip     = var.network.dns_service_ip
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [var.cluster_identity_id]
  }

  kubelet_identity {
    user_assigned_identity_id = var.kubelet_identity_id
  }

  tags = var.tags
}

# Output the cluster credentials
resource "azurerm_kubernetes_cluster_node_pool" "user_node_pool" {
  count                 = var.node_pool.enable_auto_scaling ? 1 : 0
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.node_pool.vm_size
  node_count            = var.node_pool.node_count
  min_count             = var.node_pool.min_count
  max_count             = var.node_pool.max_count
  enable_auto_scaling   = true
  os_disk_size_gb       = var.node_pool.os_disk_size_gb
  vnet_subnet_id        = var.network.subnet_id
  tags                  = var.tags
} 