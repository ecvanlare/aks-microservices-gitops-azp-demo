resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name                = "default"
    node_count          = var.node_pool.node_count
    vm_size             = var.node_pool.vm_size
    os_disk_size_gb     = var.node_pool.os_disk_size_gb
    enable_auto_scaling = true
    min_count           = var.node_pool.min_count
    max_count           = var.node_pool.max_count
    vnet_subnet_id      = var.network.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  # Kubelet identity for node operations (like pulling images)
  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.kubelet.client_id
    object_id                 = azurerm_user_assigned_identity.kubelet.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.kubelet.id
  }

  network_profile {
    network_plugin     = var.network.plugin
    network_policy     = var.network.policy
    load_balancer_sku  = "standard"
    service_cidr       = var.network.service_cidr
    dns_service_ip     = var.network.dns_service_ip
  }

  tags = var.tags
}

# Separate user-assigned identity for kubelet
resource "azurerm_user_assigned_identity" "kubelet" {
  name                = "${var.name}-kubelet-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
} 