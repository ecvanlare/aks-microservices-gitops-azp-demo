terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.9"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.4"
    }
  }
  required_version = ">= 1.4.0"
}

provider "azurerm" {
  features {}
}

provider "azuread" {
} 