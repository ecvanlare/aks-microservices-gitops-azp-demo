# Subnet outputs
output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = azurerm_subnet.this["aks-private"].id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = azurerm_subnet.this["aks-public"].id
}

# NSG outputs
output "private_nsg_id" {
  description = "ID of the private subnet NSG"
  value       = azurerm_network_security_group.this["private"].id
}

output "public_nsg_id" {
  description = "ID of the public subnet NSG"
  value       = azurerm_network_security_group.this["public"].id
}