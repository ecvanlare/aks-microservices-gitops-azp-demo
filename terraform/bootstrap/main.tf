resource "azurerm_resource_group" "infrastructure" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = merge(var.tags, var.resource_group_tags)
}

resource "azurerm_storage_account" "tfstate" {
  name                            = var.storage_account_name
  resource_group_name             = azurerm_resource_group.infrastructure.name
  location                        = azurerm_resource_group.infrastructure.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = var.storage_blob_versioning_enabled

    delete_retention_policy {
      days = var.storage_soft_delete_retention_days
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.storage_container_name
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = var.storage_container_access_type
}