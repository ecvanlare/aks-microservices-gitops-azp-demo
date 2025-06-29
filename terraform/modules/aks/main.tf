resource "azurerm_kubernetes_cluster" "aks" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.dns_prefix
  private_cluster_enabled = true

  default_node_pool {
    name                = var.node_pool.name
    node_count          = var.node_pool.node_count
    vm_size             = var.node_pool.vm_size
    os_disk_size_gb     = var.node_pool.os_disk_size_gb
    enable_auto_scaling = var.node_pool.enable_auto_scaling
    min_count           = var.node_pool.min_count
    max_count           = var.node_pool.max_count
    vnet_subnet_id      = var.network.subnet_id
    max_pods            = var.max_pods_per_node
  }

  network_profile {
    network_plugin    = var.network.plugin
    network_policy    = var.network.policy
    service_cidr      = var.network.service_cidr
    dns_service_ip    = var.network.dns_service_ip
    load_balancer_sku = var.load_balancer_sku
    outbound_type     = var.outbound_type
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.cluster_identity_id]
  }

  kubelet_identity {
    user_assigned_identity_id = var.kubelet_identity_id
    client_id                 = var.kubelet_identity_client_id
    object_id                 = var.kubelet_identity_object_id
  }

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = var.aad_rbac.admin_group_object_ids
    azure_rbac_enabled     = var.aad_rbac.azure_rbac_enabled
  }

  tags = var.tags
}

# Output the cluster credentials
resource "azurerm_kubernetes_cluster_node_pool" "user_node_pool" {
  count                 = var.node_pool.enable_auto_scaling ? 1 : 0
  name                  = var.user_node_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.node_pool.vm_size
  node_count            = var.node_pool.node_count
  min_count             = var.node_pool.min_count
  max_count             = var.node_pool.max_count
  enable_auto_scaling   = var.node_pool.enable_auto_scaling
  os_disk_size_gb       = var.node_pool.os_disk_size_gb
  vnet_subnet_id        = var.network.subnet_id
  max_pods              = var.max_pods_per_node
  tags                  = var.tags
} 