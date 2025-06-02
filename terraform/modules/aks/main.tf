resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.aks_dns_prefix

  default_node_pool {
    name                = "default"
    node_count          = var.aks_node_count
    vm_size             = var.aks_vm_size
    os_disk_size_gb     = var.aks_os_disk_size_gb
    enable_auto_scaling = var.aks_enable_auto_scaling
    min_count           = var.aks_min_count
    max_count           = var.aks_max_count
    vnet_subnet_id      = var.subnet_id
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