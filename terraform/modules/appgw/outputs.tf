output "id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "name" {
  description = "The name of the Application Gateway"
  value       = azurerm_application_gateway.appgw.name
}

output "private_ip_address" {
  description = "The private IP address of the Application Gateway"
  value       = azurerm_application_gateway.appgw.frontend_ip_configuration[0].private_ip_address
}

output "backend_address_pools" {
  description = "The backend address pools of the Application Gateway"
  value       = azurerm_application_gateway.appgw.backend_address_pool
} 