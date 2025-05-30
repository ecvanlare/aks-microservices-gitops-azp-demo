resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-online-boutique"
  resource_group_name = azurerm_resource_group.rg_online_boutique.name
  location            = azurerm_resource_group.rg_online_boutique.location
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.rg_online_boutique.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]

  # Enable service endpoints for AKS
  service_endpoints = [
    "Microsoft.ContainerRegistry",
    "Microsoft.KeyVault",
    "Microsoft.ServiceBus"
  ]
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.rg_online_boutique.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group for AKS subnet
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "nsg-aks"
  location            = azurerm_resource_group.rg_online_boutique.location
  resource_group_name = azurerm_resource_group.rg_online_boutique.name
  tags                = var.tags

  # Allow frontend access
  security_rule {
    name                       = "AllowFrontend"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow Redis access
  security_rule {
    name                       = "AllowRedis"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6379"
    source_address_prefix      = "10.0.0.0/24"  # Only allow from within the subnet
    destination_address_prefix = "*"
  }

  # Allow internal service communication
  security_rule {
    name                       = "AllowInternal"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/24"  # Only allow from within the subnet
    destination_address_prefix = "10.0.0.0/24"
  }
}

# Associate NSG with AKS subnet
resource "azurerm_subnet_network_security_group_association" "aks_nsg_association" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
} 