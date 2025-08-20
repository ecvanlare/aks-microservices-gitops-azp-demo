# Azure Key Vault for storing all sensitive values

resource "azurerm_key_vault" "this" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = var.purge_protection_enabled
  sku_name                    = var.sku_name
  enable_rbac_authorization   = var.enable_rbac_authorization

  network_acls {
    default_action = var.network_acls.default_action
    bypass         = var.network_acls.bypass
  }

  tags = var.tags
}

# Azure RBAC role assignments
resource "azurerm_role_assignment" "terraform_admin" {

  scope                = azurerm_key_vault.this.id
  role_definition_name = var.terraform_role_name
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "aks_secrets_user" {

  scope                = azurerm_key_vault.this.id
  role_definition_name = var.aks_role_name
  principal_id         = var.aks_managed_identity_object_id
}

# Data source for current Azure client
data "azurerm_client_config" "current" {} 