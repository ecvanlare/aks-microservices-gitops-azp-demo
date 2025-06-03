terraform {
  backend "azurerm" {
    resource_group_name  = "rg-online-boutique-bootstrap"
    storage_account_name = "stonlineboutiquebootstf"
    container_name       = "tfstate"
    key                  = "bootstrap.tfstate"
  }
}