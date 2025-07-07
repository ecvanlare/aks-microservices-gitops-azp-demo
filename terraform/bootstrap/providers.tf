terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.9"
    }
  }
  required_version = ">= 1.4.0"
}

provider "azurerm" {
  features {}
} 