resource "azurerm_kubernetes_cluster" "this" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.dns_prefix
  private_cluster_enabled = var.private_cluster_enabled

  default_node_pool {
    name                        = var.default_node_pool.name
    vm_size                     = var.default_node_pool.vm_size
    os_disk_size_gb             = var.default_node_pool.os_disk_size_gb
    min_count                   = var.default_node_pool.min_count
    max_count                   = var.default_node_pool.max_count
    vnet_subnet_id              = var.default_node_pool.subnet_id
    max_pods                    = var.default_node_pool.max_pods
    auto_scaling_enabled        = var.default_node_pool.auto_scaling_enabled
    node_labels                 = var.default_node_pool.node_labels
    temporary_name_for_rotation = "temp${var.default_node_pool.name}"
  }

  network_profile {
    network_plugin    = var.network_profile.plugin
    network_policy    = var.network_profile.policy
    service_cidr      = var.network_profile.service_cidr
    dns_service_ip    = var.network_profile.dns_service_ip
    load_balancer_sku = var.network_profile.load_balancer_sku
    outbound_type     = var.network_profile.outbound_type
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.cluster_identity_id]
  }

  kubelet_identity {
    user_assigned_identity_id = var.kubelet_identity.user_assigned_identity_id
    client_id                 = var.kubelet_identity.client_id
    object_id                 = var.kubelet_identity.object_id
  }

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = [var.admin_group_object_id]
    azure_rbac_enabled     = var.azure_rbac_enabled
  }

  # Cluster autoscaler
  dynamic "auto_scaler_profile" {
    for_each = var.enable_cluster_autoscaler ? [1] : []
    content {
      scale_down_delay_after_add       = var.autoscaler_profile.scale_down_delay_after_add
      scale_down_delay_after_delete    = var.autoscaler_profile.scale_down_delay_after_delete
      scale_down_delay_after_failure   = var.autoscaler_profile.scale_down_delay_after_failure
      scan_interval                    = var.autoscaler_profile.scan_interval
      scale_down_unneeded              = var.autoscaler_profile.scale_down_unneeded
      scale_down_unready               = var.autoscaler_profile.scale_down_unready
      scale_down_utilization_threshold = var.autoscaler_profile.scale_down_utilization_threshold
    }
  }

  tags = var.tags
}

# Additional node pools
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = var.additional_node_pools

  name                        = each.value.name
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.this.id
  vm_size                     = each.value.vm_size
  min_count                   = each.value.min_count
  max_count                   = each.value.max_count
  os_disk_size_gb             = each.value.os_disk_size_gb
  vnet_subnet_id              = each.value.subnet_id
  max_pods                    = each.value.max_pods
  auto_scaling_enabled        = each.value.auto_scaling_enabled
  temporary_name_for_rotation = "temp${each.value.name}"
  node_taints                 = each.value.node_taints
  node_labels                 = each.value.node_labels
  tags                        = merge(var.tags, each.value.tags)
} 