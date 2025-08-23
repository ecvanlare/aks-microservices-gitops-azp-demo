resource "azurerm_kubernetes_cluster" "this" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.dns_prefix
  private_cluster_enabled = var.private_cluster_enabled

  default_node_pool {
    name                        = var.node_pool.name
    vm_size                     = var.node_pool.vm_size
    os_disk_size_gb             = var.node_pool.os_disk_size_gb
    min_count                   = var.node_pool.min_count
    max_count                   = var.node_pool.max_count
    vnet_subnet_id              = var.network.private_subnet_id
    max_pods                    = var.node_pool.max_pods
    auto_scaling_enabled        = var.node_pool.auto_scaling_enabled
    node_labels                 = var.node_pool.node_labels
    temporary_name_for_rotation = "temp${var.node_pool.name}"
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

  # Enable cluster autoscaler for automatic node scaling
  dynamic "auto_scaler_profile" {
    for_each = var.enable_cluster_autoscaler ? [1] : []
    content {
      # Scale-down configuration (supported attributes)
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

# User node pool for workload separation
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                        = var.user_node_pool.name
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.this.id
  vm_size                     = var.user_node_pool.vm_size
  min_count                   = var.user_node_pool.min_count
  max_count                   = var.user_node_pool.max_count
  os_disk_size_gb             = var.user_node_pool.os_disk_size_gb
  vnet_subnet_id              = var.network.private_subnet_id
  max_pods                    = var.user_node_pool.max_pods
  auto_scaling_enabled        = var.user_node_pool.auto_scaling_enabled
  temporary_name_for_rotation = "temp${var.user_node_pool.name}"
  node_taints                 = var.user_node_pool.node_taints
  node_labels                 = var.user_node_pool.node_labels
  tags                        = var.tags
}

# Dedicated ingress node pool for ingress controllers
resource "azurerm_kubernetes_cluster_node_pool" "ingress" {
  name                        = var.ingress_node_pool.name
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.this.id
  vm_size                     = var.ingress_node_pool.vm_size
  min_count                   = var.ingress_node_pool.min_count
  max_count                   = var.ingress_node_pool.max_count
  os_disk_size_gb             = var.ingress_node_pool.os_disk_size_gb
  vnet_subnet_id              = var.network.ingress_subnet_id
  max_pods                    = var.ingress_node_pool.max_pods
  auto_scaling_enabled        = var.ingress_node_pool.auto_scaling_enabled
  temporary_name_for_rotation = "temp${var.ingress_node_pool.name}"
  node_taints                 = var.ingress_node_pool.node_taints
  node_labels                 = var.ingress_node_pool.node_labels
  tags                        = var.tags
} 