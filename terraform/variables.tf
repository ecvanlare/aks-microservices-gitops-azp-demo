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
