# Resource Group Module
module "resource_group" {
  source = "./modules/resource_group"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Create managed identity for cluster operations
resource "azurerm_user_assigned_identity" "cluster" {
  name                = "${var.aks_name}-cluster"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tags                = var.tags
}

# Create managed identity for kubelet operations
resource "azurerm_user_assigned_identity" "kubelet" {
  name                = "${var.aks_name}-kubelet"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tags                = var.tags
}

# Create managed identity for ACR push (used by CI/CD)
resource "azurerm_user_assigned_identity" "acr_push" {
  name                = "${var.aks_name}-acr-push"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tags                = var.tags
}

# Grant cluster identity the Managed Identity Operator role for kubelet identity
module "cluster_kubelet_operator" {
  source = "./modules/identity"

  scope                = azurerm_user_assigned_identity.kubelet.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.cluster.principal_id
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

# AKS Subnet Module
module "aks_subnet" {
  source = "./modules/network/subnet"

  name                = var.subnets.aks.name
  resource_group_name = module.resource_group.resource_group_name
  vnet_name           = module.vnet.vnet_name
  address_prefixes    = var.subnets.aks.address_prefixes
  service_endpoints   = var.subnets.aks.service_endpoints
}

# Application Gateway Subnet Module
module "appgw_subnet" {
  source = "./modules/network/subnet"

  name                = var.subnets.appgw.name
  resource_group_name = module.resource_group.resource_group_name
  vnet_name           = module.vnet.vnet_name
  address_prefixes    = var.subnets.appgw.address_prefixes
  service_endpoints   = var.subnets.appgw.service_endpoints
}

# AKS Network Security Group Module
module "nsg" {
  source = "./modules/network/nsg"

  name                = "nsg-aks"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  subnet_id           = module.aks_subnet.subnet_id
  rules               = var.nsg_rules
  enable_admin_source_restriction = var.enable_admin_source_restriction
  admin_source_ips    = var.admin_source_ips
  tags                = var.tags
}

# Identity assignment for AKS to pull from ACR
module "aks_acr_pull" {
  source = "./modules/identity"

  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.kubelet.principal_id
}

# Identity assignment for ACR push operations
module "acr_push" {
  source = "./modules/identity"

  scope                = module.acr.acr_id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.acr_push.principal_id
}

# Azure AD Groups (must be created before AKS)
resource "azuread_group" "aks_admins" {
  display_name     = var.admin_group_name
  mail_nickname    = var.admin_group_name
  security_enabled = true
  description      = "AKS Cluster Administrators"
}

resource "azuread_group" "aks_developers" {
  display_name     = var.developer_group_name
  mail_nickname    = var.developer_group_name
  security_enabled = true
  description      = "AKS Developers - Can create/modify resources"
}

resource "azuread_group" "aks_viewers" {
  display_name     = var.viewer_group_name
  mail_nickname    = var.viewer_group_name
  security_enabled = true
  description      = "AKS Viewers - Read-only access"
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
    subnet_id      = module.aks_subnet.subnet_id
    service_cidr   = var.aks_service_cidr
    dns_service_ip = var.aks_dns_service_ip
  }
  cluster_identity_id        = azurerm_user_assigned_identity.cluster.id
  kubelet_identity_id        = azurerm_user_assigned_identity.kubelet.id
  kubelet_identity_client_id = azurerm_user_assigned_identity.kubelet.client_id
  kubelet_identity_object_id = azurerm_user_assigned_identity.kubelet.principal_id
  aad_rbac = {
    admin_group_object_ids = [azuread_group.aks_admins.id]
    azure_rbac_enabled     = true
    user_groups = [
      {
        name      = var.admin_group_name
        object_id = azuread_group.aks_admins.id
        roles     = [var.admin_role]
      },
      {
        name      = var.developer_group_name
        object_id = azuread_group.aks_developers.id
        roles     = [var.developer_role]
      },
      {
        name      = var.viewer_group_name
        object_id = azuread_group.aks_viewers.id
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
module "user_group_roles" {
  source = "./modules/identity"
  count  = 3

  scope                = module.aks.cluster_id
  role_definition_name = count.index == 0 ? var.admin_role : count.index == 1 ? var.developer_role : var.viewer_role
  principal_id         = count.index == 0 ? azuread_group.aks_admins.id : count.index == 1 ? azuread_group.aks_developers.id : azuread_group.aks_viewers.id
} 