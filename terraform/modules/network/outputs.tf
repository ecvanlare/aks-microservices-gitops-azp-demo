# Subnet outputs
output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = azurerm_subnet.this["aks-private"].id
}

output "ingress_subnet_id" {
  description = "ID of the ingress subnet"
  value       = azurerm_subnet.this["aks-ingress"].id
}

# NSG outputs
output "private_nsg_id" {
  description = "ID of the private subnet NSG"
  value       = azurerm_network_security_group.this["private"].id
}

output "ingress_nsg_id" {
  description = "ID of the ingress subnet NSG"
  value       = azurerm_network_security_group.this["ingress"].id
}