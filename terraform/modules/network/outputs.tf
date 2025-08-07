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

# NAT Gateway outputs
output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = azurerm_nat_gateway.main.id
}

output "nat_gateway_public_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = azurerm_public_ip.nat_gateway.ip_address
}