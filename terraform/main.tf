# =============================================================================
# FOUNDATION RESOURCES
# =============================================================================

# Resource Group Module
module "resource_group" {
  source = "./modules/resource_group"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# =============================================================================
# IDENTITY MANAGEMENT
# =============================================================================

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

# Azure AD Groups 
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

# =============================================================================
# NETWORK INFRASTRUCTURE
# =============================================================================

# Network Infrastructure
module "network" {
  source = "./modules/network"

  # Common
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tags                = var.tags

  # Virtual Network
  vnet_name     = var.vnet_name
  address_space = [var.vnet_address_space]

  # AKS Subnet
  subnet_name             = var.subnets["aks-cluster"].name
  subnet_address_prefixes = var.subnets["aks-cluster"].address_prefixes
  service_endpoints       = var.subnets["aks-cluster"].service_endpoints

  # Network Security Group
  nsg_name       = var.nsg_name
  security_rules = var.nsg_rules
}

# =============================================================================
# CONTAINER REGISTRY
# =============================================================================

# Azure Container Registry Module
module "acr" {
  source = "./modules/acr"

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  name                = var.acr_name
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
  tags                = var.tags
}

# =============================================================================
# ROLE ASSIGNMENTS & PERMISSIONS
# =============================================================================

# Role assignments configuration
locals {

  # User group role assignments
  role_assignments = {
    admins     = { group = "admins", role = var.admin_role }
    developers = { group = "developers", role = var.developer_role }
    viewers    = { group = "viewers", role = var.viewer_role }
  }

  # Key Vault role assignments
  keyvault_role_assignments = {
    admins     = { group = "admins", role = var.keyvault_admin_role }
    developers = { group = "developers", role = var.keyvault_secrets_officer_role }
    viewers    = { group = "viewers", role = var.keyvault_reader_role }
  }
}

# System Identity Role Assignments

# Grant cluster identity the Managed Identity Operator role for kubelet identity
module "cluster_kubelet_operator" {
  source = "./modules/identity"

  scope                = azurerm_user_assigned_identity.identities["kubelet"].id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.identities["cluster"].principal_id
  description          = var.role_assignment_defaults.description
}

# Identity assignment for AKS to pull from ACR
module "aks_acr_pull" {
  source = "./modules/identity"

  scope                = module.acr.acr_id
  role_definition_name = var.acr_pull_role_name
  principal_id         = azurerm_user_assigned_identity.identities["kubelet"].principal_id
  description          = var.role_assignment_defaults.description
}

# Identity assignment for ACR push operations
module "acr_push" {
  source = "./modules/identity"

  scope                = module.acr.acr_id
  role_definition_name = var.acr_push_role_name
  principal_id         = azurerm_user_assigned_identity.identities["acr_push"].principal_id
  description          = var.role_assignment_defaults.description
}

# Grant AKS cluster identity Network Contributor role for LoadBalancer services
module "aks_network_contributor" {
  source = "./modules/identity"

  scope                = module.resource_group.resource_group_id
  role_definition_name = var.network_contributor_role_name
  principal_id         = azurerm_user_assigned_identity.identities["cluster"].principal_id
  description          = var.role_assignment_defaults.description
}

# =============================================================================
# KUBERNETES CLUSTER
# =============================================================================

# Azure Kubernetes Service Module
module "aks" {
  source = "./modules/aks"

  # Basic Configuration
  resource_group_name     = module.resource_group.resource_group_name
  location                = module.resource_group.resource_group_location
  name                    = var.aks_name
  dns_prefix              = var.aks_dns_prefix
  private_cluster_enabled = var.aks_private_cluster_enabled

  # Node Pools Configuration
  node_pool         = var.aks_node_pool
  user_node_pool    = var.aks_user_node_pool
  ingress_node_pool = var.aks_ingress_node_pool

  # Network Configuration
  network = {
    plugin         = var.aks_network_plugin
    policy         = null
    subnet_id      = module.network.subnet_id
    service_cidr   = var.aks_service_cidr
    dns_service_ip = var.aks_dns_service_ip
  }
  load_balancer_sku = var.aks_load_balancer_sku
  outbound_type     = var.aks_outbound_type

  # Cluster Autoscaler Configuration
  enable_cluster_autoscaler = var.aks_enable_cluster_autoscaler
  autoscaler_profile        = var.aks_autoscaler_profile

  # Identity Configuration
  cluster_identity_id        = azurerm_user_assigned_identity.identities["cluster"].id
  kubelet_identity_id        = azurerm_user_assigned_identity.identities["kubelet"].id
  kubelet_identity_client_id = azurerm_user_assigned_identity.identities["kubelet"].client_id
  kubelet_identity_object_id = azurerm_user_assigned_identity.identities["kubelet"].principal_id

  # RBAC Configuration
  aad_rbac = {
    admin_group_object_ids = [azuread_group.aks_groups["admins"].object_id]
    azure_rbac_enabled     = true
    user_groups = [
      {
        name      = var.admin_group_name
        object_id = azuread_group.aks_groups["admins"].object_id
        roles     = [var.admin_role]
      },
      {
        name      = var.developer_group_name
        object_id = azuread_group.aks_groups["developers"].object_id
        roles     = [var.developer_role]
      },
      {
        name      = var.viewer_group_name
        object_id = azuread_group.aks_groups["viewers"].object_id
        roles     = [var.viewer_role]
      }
    ]
  }

  tags = var.tags

  depends_on = [
    module.cluster_kubelet_operator,
    module.aks_network_contributor
  ]
}

# =============================================================================
# SECURITY & SECRETS MANAGEMENT
# =============================================================================

# Key Vault Module for storing all sensitive values
module "keyvault" {
  source = "./modules/keyvault"

  key_vault_name                 = "kv-${var.environment}-${var.project_name}"
  location                       = var.location
  resource_group_name            = module.resource_group.resource_group_name
  aks_managed_identity_object_id = module.aks.kubelet_identity_object_id
  enable_rbac_authorization      = true

  # Key Vault Configuration
  soft_delete_retention_days = var.keyvault_soft_delete_retention_days
  purge_protection_enabled   = var.keyvault_purge_protection_enabled
  sku_name                   = var.keyvault_sku_name
  network_acls               = var.keyvault_network_acls

  # Role Names
  terraform_role_name = var.keyvault_terraform_role_name
  aks_role_name       = var.keyvault_aks_role_name

  tags = var.tags
}

# User and Key Vault Role Assignments
module "user_group_roles" {
  source   = "./modules/identity"
  for_each = local.role_assignments

  scope                = module.aks.cluster_id
  role_definition_name = each.value.role
  principal_id         = azuread_group.aks_groups[each.value.group].object_id
  description          = var.role_assignment_defaults.description
}

module "keyvault_user_group_roles" {
  source   = "./modules/identity"
  for_each = local.keyvault_role_assignments

  scope                = module.keyvault.key_vault_id
  role_definition_name = each.value.role
  principal_id         = azuread_group.aks_groups[each.value.group].object_id
  description          = var.role_assignment_defaults.description

  depends_on = [module.keyvault]
}