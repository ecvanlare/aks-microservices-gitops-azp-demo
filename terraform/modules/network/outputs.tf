# Used by AKS configuration
output "subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks_subnet.id
}