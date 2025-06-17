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
  tags                = var.tags
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
  cluster_identity_id = azurerm_user_assigned_identity.cluster.id
  kubelet_identity_id = azurerm_user_assigned_identity.kubelet.id
  tags                = var.tags
}

# Identity assignment for AKS to pull from ACR
module "aks_acr_pull" {
  source = "./modules/identity"

  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.cluster.principal_id
}

# Identity assignment for ACR push operations
module "acr_push" {
  source = "./modules/identity"

  scope                = module.acr.acr_id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.acr_push.principal_id
}

