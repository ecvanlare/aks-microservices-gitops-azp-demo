output "id" {
  description = "The ID of the role assignment"
  value       = azurerm_role_assignment.identity.id
}

output "principal_id" {
  description = "The ID of the principal the role is assigned to"
  value       = azurerm_role_assignment.identity.principal_id
}

output "scope" {
  description = "The scope of the role assignment"
  value       = azurerm_role_assignment.identity.scope
} 