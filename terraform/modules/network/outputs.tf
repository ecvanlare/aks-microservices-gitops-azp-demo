# Subnet outputs
output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = azurerm_subnet.subnets["aks-private"].id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = azurerm_subnet.subnets["aks-public"].id
}

# NSG outputs
output "private_nsg_id" {
  description = "ID of the private subnet NSG"
  value       = azurerm_network_security_group.nsg["private"].id
}

output "public_nsg_id" {
  description = "ID of the public subnet NSG"
  value       = azurerm_network_security_group.nsg["public"].id
}