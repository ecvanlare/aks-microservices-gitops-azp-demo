resource "azurerm_resource_group" "bootstrap" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = merge(var.tags, var.resource_group_tags, {
  })
}

resource "azurerm_storage_account" "tfstate" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.bootstrap.name
  location                 = azurerm_resource_group.bootstrap.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = merge(var.tags, var.storage_account_tags, {
  })
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}