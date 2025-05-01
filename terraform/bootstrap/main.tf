resource "azurerm_resource_group" "bootstrap" {
  name     = "rg-online-boutique-bootstrap"
  location = "uksouth"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "stonlineboutiquetfstate"
  resource_group_name      = azurerm_resource_group.bootstrap.name
  location                 = azurerm_resource_group.bootstrap.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = {
    environment = "bootstrap"
    purpose     = "terraform-state"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
} 