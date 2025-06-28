resource "azurerm_network_security_group" "nsg" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = var.rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = lookup(security_rule.value, "description", null)
    }
  }

  # Conditional admin access rules
  dynamic "security_rule" {
    for_each = var.enable_admin_source_restriction && length(var.admin_source_ips) > 0 ? var.admin_source_ips : []
    content {
      name                       = "allow-admin-kubernetes-api-${index(var.admin_source_ips, security_rule.value)}"
      priority                   = 90
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "6443"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
      description                = "Allow Kubernetes API access from admin IP ${security_rule.value}"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.nsg.id
} 