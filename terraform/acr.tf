resource "azurerm_container_registry" "acr_online_boutique" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg_online_boutique.name
  location            = azurerm_resource_group.rg_online_boutique.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled

  tags = var.tags
} 