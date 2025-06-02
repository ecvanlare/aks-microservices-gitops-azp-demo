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
    enable_auto_scaling = var.node_pool.enable_auto_scaling
    min_count           = var.node_pool.min_count
    max_count           = var.node_pool.max_count
    vnet_subnet_id      = var.network.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = var.network.plugin
    network_policy     = var.network.policy
    load_balancer_sku  = "standard"
  }

  tags = var.tags
} 