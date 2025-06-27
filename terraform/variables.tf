# Resource Group Variables
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-online-boutique"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default = {
    environment = "prod"
    project     = "online-boutique"
    managed_by  = "terraform"
  }
}

# Network Variables
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-online-boutique"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnets" {
  description = "Subnet configurations"
  type = map(object({
    name              = string
    address_prefixes  = list(string)
    service_endpoints = list(string)
  }))
  default = {
    aks = {
      name              = "snet-aks"
      address_prefixes  = ["10.0.0.0/24"]
      service_endpoints = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
    }
    appgw = {
      name              = "snet-appgw"
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = []
    }
  }
}

# ACR Variables
variable "acr_name" {
  description = "Name of the container registry"
  type        = string
  default     = "acronlineboutique"
}

variable "acr_sku" {
  description = "SKU of the container registry"
  type        = string
  default     = "Standard"
}

variable "acr_admin_enabled" {
  description = "Enable admin access to the container registry"
  type        = bool
  default     = false
}

# AKS Variables
variable "aks_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-online-boutique"
}

variable "aks_dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "online-boutique"
}

variable "aks_node_pool" {
  description = "The default node pool configuration for AKS"
  type = object({
    name                = string
    node_count          = number
    vm_size             = string
    os_disk_size_gb     = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
  })
  default = {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_B2s"
    os_disk_size_gb     = 30
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
  }
}

variable "aks_network_plugin" {
  description = "Network plugin for AKS"
  type        = string
  default     = "kubenet"
}

variable "aks_network_policy" {
  description = "Network policy for AKS"
  type        = string
  default     = "calico"
}

variable "aks_service_cidr" {
  description = "Service CIDR for AKS cluster"
  type        = string
  default     = "172.16.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "DNS service IP for AKS cluster (must be within service_cidr)"
  type        = string
  default     = "172.16.0.10"
}

# NSG Variables
variable "nsg_rules" {
  description = "Network security group rules"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
    description                = string
  }))
  default = [
    {
      name                       = "allow-kubernetes-api"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "6443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow Kubernetes API server access from VNet"
    },
    {
      name                       = "allow-https"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow HTTPS from VNet"
    },
    {
      name                       = "allow-http"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow HTTP from VNet"
    },
    {
      name                       = "allow-ssh"
      priority                   = 130
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow SSH from VNet"
    },
    {
      name                       = "allow-kubelet"
      priority                   = 140
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "10250"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow Kubelet API from VNet"
    },
    {
      name                       = "allow-nodeport-services"
      priority                   = 150
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "30000-32767"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow NodePort services from VNet"
    },
    {
      name                       = "deny-all-inbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny all other inbound traffic"
    }
  ]
}

# Source IP restrictions for admin access
variable "admin_source_ips" {
  description = "Source IP addresses allowed for admin access (CIDR notation)"
  type        = list(string)
  default     = []
}

variable "enable_admin_source_restriction" {
  description = "Enable source IP restrictions for admin access"
  type        = bool
  default     = false
}

# Azure AD Group Names
variable "admin_group_name" {
  description = "Name for the AKS admin group"
  type        = string
  default     = "aks-admins"
}

variable "developer_group_name" {
  description = "Name for the AKS developer group"
  type        = string
  default     = "aks-developers"
}

variable "viewer_group_name" {
  description = "Name for the AKS viewer group"
  type        = string
  default     = "aks-viewers"
}

# Azure RBAC Role Names
variable "admin_role" {
  description = "Azure RBAC role for admin group"
  type        = string
  default     = "Azure Kubernetes Service RBAC Cluster Admin"
}

variable "developer_role" {
  description = "Azure RBAC role for developer group"
  type        = string
  default     = "Azure Kubernetes Service RBAC Writer"
}

variable "viewer_role" {
  description = "Azure RBAC role for viewer group"
  type        = string
  default     = "Azure Kubernetes Service RBAC Reader"
}

# Application Gateway Load Balancer Variables
variable "appgw_name" {
  description = "Name of the Application Gateway"
  type        = string
  default     = "appgw-online-boutique"
}

variable "appgw_sku" {
  description = "SKU of the Application Gateway"
  type = object({
    name     = string
    tier     = string
    capacity = number
  })
  default = {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
}

variable "appgw_frontend_ip_configuration" {
  description = "Frontend IP configuration for Application Gateway"
  type = object({
    name                 = string
    subnet_id            = string
    private_ip_address   = string
    private_ip_allocation = string
  })
  default = {
    name                  = "appGwFrontendIP"
    subnet_id             = null  # Will be set in main.tf
    private_ip_address    = "10.0.1.10"
    private_ip_allocation = "Static"
  }
}

variable "appgw_backend_address_pools" {
  description = "Backend address pools for Application Gateway"
  type = list(object({
    name = string
    fqdns = list(string)
  }))
  default = [
    {
      name  = "aks-backend-pool"
      fqdns = []
    }
  ]
}

variable "appgw_http_listeners" {
  description = "HTTP listeners for Application Gateway"
  type = list(object({
    name                           = string
    frontend_ip_configuration_name = string
    frontend_port_name             = string
    protocol                       = string
    host_name                      = string
  }))
  default = [
    {
      name                           = "http-listener"
      frontend_ip_configuration_name = "appGwFrontendIP"
      frontend_port_name             = "port_80"
      protocol                       = "Http"
      host_name                      = null
    }
  ]
}

variable "appgw_request_routing_rules" {
  description = "Request routing rules for Application Gateway"
  type = list(object({
    name                       = string
    rule_type                  = string
    http_listener_name         = string
    backend_address_pool_name  = string
    backend_http_settings_name = string
  }))
  default = [
    {
      name                       = "routing-rule"
      rule_type                  = "Basic"
      http_listener_name         = "http-listener"
      backend_address_pool_name  = "aks-backend-pool"
      backend_http_settings_name = "http-settings"
    }
  ]
}

variable "appgw_frontend_ip_name" {
  description = "Name for the Application Gateway frontend IP configuration"
  type        = string
  default     = "appGwFrontendIP"
}

variable "appgw_backend_pool_name" {
  description = "Name for the Application Gateway backend address pool"
  type        = string
  default     = "aks-backend-pool"
}

variable "appgw_http_listener_name" {
  description = "Name for the Application Gateway HTTP listener"
  type        = string
  default     = "http-listener"
}

variable "appgw_frontend_port_name" {
  description = "Name for the Application Gateway frontend port"
  type        = string
  default     = "port_80"
}

variable "appgw_protocol" {
  description = "Protocol for the Application Gateway listener"
  type        = string
  default     = "Http"
}

variable "appgw_routing_rule_name" {
  description = "Name for the Application Gateway routing rule"
  type        = string
  default     = "routing-rule"
}

variable "appgw_rule_type" {
  description = "Type for the Application Gateway routing rule"
  type        = string
  default     = "Basic"
}

variable "appgw_backend_http_settings_name" {
  description = "Name for the Application Gateway backend HTTP settings"
  type        = string
  default     = "http-settings"
}

variable "appgw_backend_fqdns" {
  description = "FQDNs for the Application Gateway backend address pool"
  type        = list(string)
  default     = []
}

variable "appgw_host_name" {
  description = "Host name for the Application Gateway HTTP listener (null for none)"
  type        = string
  default     = null
}
