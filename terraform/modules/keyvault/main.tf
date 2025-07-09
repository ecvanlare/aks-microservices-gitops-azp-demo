# Azure Key Vault for storing all sensitive values

resource "azurerm_key_vault" "main" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = var.purge_protection_enabled
  sku_name                    = var.sku_name

  # Enable Azure RBAC instead of access policies
  enable_rbac_authorization = var.enable_rbac_authorization

  network_acls {
    default_action = var.network_acls.default_action
    bypass         = var.network_acls.bypass
  }

  tags = var.tags
}

# Access policies (legacy approach - used when RBAC is disabled)
resource "azurerm_key_vault_access_policy" "terraform" {
  count = var.enable_rbac_authorization ? 0 : 1

  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
  ]
}

resource "azurerm_key_vault_access_policy" "aks" {
  count = var.enable_rbac_authorization ? 0 : 1

  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.aks_managed_identity_object_id

  secret_permissions = [
    "Get", "List"
  ]
}

# Azure RBAC role assignments (modern approach)
resource "azurerm_role_assignment" "terraform_keyvault_admin" {
  count = var.enable_rbac_authorization ? 1 : 0

  scope                = azurerm_key_vault.main.id
  role_definition_name = var.terraform_role_name
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "aks_keyvault_secrets_user" {
  count = var.enable_rbac_authorization ? 1 : 0

  scope                = azurerm_key_vault.main.id
  role_definition_name = var.aks_role_name
  principal_id         = var.aks_managed_identity_object_id
}

# Data source for current Azure client
data "azurerm_client_config" "current" {} 