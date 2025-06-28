# Resource Group Module
module "resource_group" {
  source = "./modules/resource_group"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Create managed identities
resource "azurerm_user_assigned_identity" "identities" {
  for_each = {
    cluster  = "${var.aks_name}-cluster"
    kubelet  = "${var.aks_name}-kubelet"
    acr_push = "${var.aks_name}-acr-push"
  }

  name                = each.value
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tags                = var.tags
}

# Grant cluster identity the Managed Identity Operator role for kubelet identity
module "cluster_kubelet_operator" {
  source = "./modules/identity"

  scope                = azurerm_user_assigned_identity.identities["kubelet"].id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.identities["cluster"].principal_id
}

# Azure Container Registry Module
module "acr" {
  source = "./modules/acr"

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  name                = var.acr_name
  sku                 = var.acr_sku
  admin_enabled       = false # Disable admin access since we're using managed identity
  tags                = var.tags
}

# Virtual Network Module
module "vnet" {
  source = "./modules/network/vnet"

  name                = var.vnet_name
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

# Subnet Modules
module "subnets" {
  source   = "./modules/network/subnet"
  for_each = var.subnets

  name                = each.value.name
  resource_group_name = module.resource_group.resource_group_name
  vnet_name           = module.vnet.vnet_name
  address_prefixes    = each.value.address_prefixes
  service_endpoints   = each.value.service_endpoints
}

# AKS Network Security Group Module
module "nsg" {
  source = "./modules/network/nsg"

  name                            = "nsg-aks"
  resource_group_name             = module.resource_group.resource_group_name
  location                        = module.resource_group.resource_group_location
  subnet_id                       = module.subnets["aks"].subnet_id
  rules                           = var.nsg_rules
  enable_admin_source_restriction = var.enable_admin_source_restriction
  admin_source_ips                = var.admin_source_ips
  tags                            = var.tags
}

# Identity assignment for AKS to pull from ACR
module "aks_acr_pull" {
  source = "./modules/identity"

  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.identities["kubelet"].principal_id
}

# Identity assignment for ACR push operations
module "acr_push" {
  source = "./modules/identity"

  scope                = module.acr.acr_id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.identities["acr_push"].principal_id
}

# Azure AD Groups (must be created before AKS)
resource "azuread_group" "aks_groups" {
  for_each = {
    admins     = { name = var.admin_group_name, description = "AKS Cluster Administrators" }
    developers = { name = var.developer_group_name, description = "AKS Developers - Can create/modify resources" }
    viewers    = { name = var.viewer_group_name, description = "AKS Viewers - Read-only access" }
  }

  display_name     = each.value.name
  mail_nickname    = each.value.name
  security_enabled = true
  description      = each.value.description
}

# Azure Kubernetes Service Module
module "aks" {
  source = "./modules/aks"

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  name                = var.aks_name
  dns_prefix          = var.aks_dns_prefix
  node_pool           = var.aks_node_pool
  network = {
    plugin         = var.aks_network_plugin
    policy         = var.aks_network_policy
    subnet_id      = module.subnets["aks"].subnet_id
    service_cidr   = var.aks_service_cidr
    dns_service_ip = var.aks_dns_service_ip
  }
  cluster_identity_id        = azurerm_user_assigned_identity.identities["cluster"].id
  kubelet_identity_id        = azurerm_user_assigned_identity.identities["kubelet"].id
  kubelet_identity_client_id = azurerm_user_assigned_identity.identities["kubelet"].client_id
  kubelet_identity_object_id = azurerm_user_assigned_identity.identities["kubelet"].principal_id
  load_balancer_sku          = var.aks_load_balancer_sku
  outbound_type              = var.aks_outbound_type
  user_node_pool_name        = var.aks_user_node_pool_name
  aad_rbac = {
    admin_group_object_ids = []
    azure_rbac_enabled     = true
    user_groups = [
      {
        name      = var.admin_group_name
        object_id = azuread_group.aks_groups["admins"].id
        roles     = [var.admin_role]
      },
      {
        name      = var.developer_group_name
        object_id = azuread_group.aks_groups["developers"].id
        roles     = [var.developer_role]
      },
      {
        name      = var.viewer_group_name
        object_id = azuread_group.aks_groups["viewers"].id
        roles     = [var.viewer_role]
      }
    ]
  }
  tags = var.tags

  depends_on = [
    module.cluster_kubelet_operator
  ]
}

# Role assignments for user groups (must be created after AKS)
locals {
  role_assignments = {
    admins     = { group = "admins", role = var.admin_role }
    developers = { group = "developers", role = var.developer_role }
    viewers    = { group = "viewers", role = var.viewer_role }
  }
}

module "user_group_roles" {
  source   = "./modules/identity"
  for_each = local.role_assignments

  scope                = module.aks.cluster_id
  role_definition_name = each.value.role
  principal_id         = azuread_group.aks_groups[each.value.group].id
}

# Create public IP for Application Gateway
resource "azurerm_public_ip" "appgw" {
  name                = "pip-appgw-online-boutique"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Create Application Gateway for load balancing
module "appgw" {
  source = "./modules/appgw"

  name                = var.appgw_name
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  subnet_id           = module.subnets["appgw"].subnet_id
  sku                 = var.appgw_sku
  frontend_ip_configuration = {
    name = var.appgw_frontend_ip_name
  }
  public_ip_address_id = azurerm_public_ip.appgw.id
  backend_address_pools = [
    {
      name  = var.appgw_backend_pool_name
      fqdns = var.appgw_backend_fqdns
    }
  ]
  http_listeners = [
    {
      name                           = var.appgw_http_listener_name
      frontend_ip_configuration_name = var.appgw_frontend_ip_name
      frontend_port_name             = var.appgw_frontend_port_name
      protocol                       = var.appgw_protocol
      host_name                      = var.appgw_host_name
    }
  ]
  request_routing_rules = [
    {
      name                       = var.appgw_routing_rule_name
      rule_type                  = var.appgw_rule_type
      http_listener_name         = var.appgw_http_listener_name
      backend_address_pool_name  = var.appgw_backend_pool_name
      backend_http_settings_name = var.appgw_backend_http_settings_name
    }
  ]
  tags = var.tags

  depends_on = [
    module.subnets["appgw"]
  ]
} 