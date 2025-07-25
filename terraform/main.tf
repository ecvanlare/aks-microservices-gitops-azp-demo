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

  name                            = var.nsg_name
  resource_group_name             = module.resource_group.resource_group_name
  location                        = module.resource_group.resource_group_location
  subnet_id                       = module.subnets["aks-cluster"].subnet_id
  rules                           = var.nsg_rules
  enable_admin_source_restriction = var.enable_admin_source_restriction
  admin_source_ips                = var.admin_source_ips
  tags                            = var.tags

  depends_on = [
    module.subnets
  ]
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
    policy         = var.aks_network_policy
    subnet_id      = module.subnets["aks-cluster"].subnet_id
    service_cidr   = var.aks_service_cidr
    dns_service_ip = var.aks_dns_service_ip
  }
  load_balancer_sku = var.aks_load_balancer_sku
  outbound_type     = var.aks_outbound_type
  max_pods_per_node = var.aks_max_pods_per_node

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

  # Timeouts Configuration
  timeouts = var.aks_timeouts

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

# =============================================================================
# ROLE ASSIGNMENTS & PERMISSIONS
# =============================================================================

# Grant cluster identity the Managed Identity Operator role for kubelet identity
module "cluster_kubelet_operator" {
  source = "./modules/identity"

  scope                = azurerm_user_assigned_identity.identities["kubelet"].id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.identities["cluster"].principal_id
  description          = var.role_assignment_description
  condition            = var.role_assignment_condition
  condition_version    = var.role_assignment_condition_version
  skip_existing_check  = var.role_assignment_skip_existing_check
}

# Identity assignment for AKS to pull from ACR
module "aks_acr_pull" {
  source = "./modules/identity"

  scope                = module.acr.acr_id
  role_definition_name = var.acr_pull_role_name
  principal_id         = azurerm_user_assigned_identity.identities["kubelet"].principal_id
  description          = var.role_assignment_description
  condition            = var.role_assignment_condition
  condition_version    = var.role_assignment_condition_version
  skip_existing_check  = var.role_assignment_skip_existing_check
}

# Identity assignment for ACR push operations
module "acr_push" {
  source = "./modules/identity"

  scope                = module.acr.acr_id
  role_definition_name = var.acr_push_role_name
  principal_id         = azurerm_user_assigned_identity.identities["acr_push"].principal_id
  description          = var.role_assignment_description
  condition            = var.role_assignment_condition
  condition_version    = var.role_assignment_condition_version
  skip_existing_check  = var.role_assignment_skip_existing_check
}

# Grant AKS cluster identity Network Contributor role for LoadBalancer services
module "aks_network_contributor" {
  source = "./modules/identity"

  scope                = module.resource_group.resource_group_id
  role_definition_name = var.network_contributor_role_name
  principal_id         = azurerm_user_assigned_identity.identities["cluster"].principal_id
  description          = var.role_assignment_description
  condition            = var.role_assignment_condition
  condition_version    = var.role_assignment_condition_version
  skip_existing_check  = var.role_assignment_skip_existing_check
}

# Role assignments for user groups (must be created after AKS)
locals {
  role_assignments = {
    admins     = { group = "admins", role = var.admin_role }
    developers = { group = "developers", role = var.developer_role }
    viewers    = { group = "viewers", role = var.viewer_role }
  }

  keyvault_role_assignments = {
    admins     = { group = "admins", role = var.keyvault_admin_role }
    developers = { group = "developers", role = var.keyvault_secrets_officer_role }
    viewers    = { group = "viewers", role = var.keyvault_reader_role }
  }
}

module "user_group_roles" {
  source   = "./modules/identity"
  for_each = local.role_assignments

  scope                = module.aks.cluster_id
  role_definition_name = each.value.role
  principal_id         = azuread_group.aks_groups[each.value.group].object_id
  description          = var.role_assignment_description
  condition            = var.role_assignment_condition
  condition_version    = var.role_assignment_condition_version
  skip_existing_check  = var.role_assignment_skip_existing_check
}

# Key Vault role assignments for user groups
module "keyvault_user_group_roles" {
  source   = "./modules/identity"
  for_each = local.keyvault_role_assignments

  scope                = module.keyvault.key_vault_id
  role_definition_name = each.value.role
  principal_id         = azuread_group.aks_groups[each.value.group].object_id
  description          = var.role_assignment_description
  condition            = var.role_assignment_condition
  condition_version    = var.role_assignment_condition_version
  skip_existing_check  = var.role_assignment_skip_existing_check

  depends_on = [
    module.keyvault
  ]
}

 