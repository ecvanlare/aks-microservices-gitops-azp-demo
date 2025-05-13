resource "azurerm_resource_group" "rg_online_boutique" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags     = var.tags
}

