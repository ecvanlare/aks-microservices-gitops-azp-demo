terraform {
  required_version = ">= 1.12.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.37"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.4"
    }
  }
}

provider "azurerm" {
  subscription_id = "e4acf9d5-393b-42b7-a392-55bbda00aac5"
  features {}
}

provider "azuread" {
} 