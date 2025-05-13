output "resource_group_name" {
  description = "The name of the Online Boutique resource group"
  value       = azurerm_resource_group.rg_online_boutique.name
}

output "resource_group_location" {
  description = "The Azure region where the Online Boutique resource group is deployed"
  value       = azurerm_resource_group.rg_online_boutique.location
}

output "resource_group_id" {
  description = "The unique identifier of the Online Boutique resource group"
  value       = azurerm_resource_group.rg_online_boutique.id
} 