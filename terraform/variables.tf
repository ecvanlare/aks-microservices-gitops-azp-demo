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



# AKS Basic Configuration
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

variable "aks_private_cluster_enabled" {
  description = "Whether to enable private cluster for AKS"
  type        = bool
  default     = false
}

variable "aks_public_network_access_enabled" {
  description = "Whether to enable public network access for AKS"
  type        = bool
  default     = true
}

# AKS Node Pools Configuration
variable "aks_node_pool" {
  description = "The default node pool configuration for AKS (system workloads)"
  type = object({
    name                = string
    vm_size             = string
    os_disk_size_gb     = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
  })
  default = {
    name                = "default"
    vm_size             = "Standard_B2ms" # 2 vCPU, 8GB RAM - better for system workloads + Redis
    os_disk_size_gb     = 30
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
  }
}

# User Node Pool Configuration (COST-OPTIMIZED for production)
variable "aks_user_node_pool" {
  description = "The user node pool configuration for AKS (application workloads)"
  type = object({
    name                = string
    vm_size             = string
    os_disk_size_gb     = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    max_pods            = number
    node_taints         = list(string)
    node_labels         = map(string)
  })
  default = {
    name                = "userpool"
    vm_size             = "Standard_B4ms" # 4 vCPU, 16GB RAM - better for 12 microservices
    os_disk_size_gb     = 64
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
    max_pods            = 50
    node_taints         = ["userpool=true:NoSchedule"]
    node_labels = {
      "agentpool" = "userpool"
    }
  }
}

variable "aks_ingress_node_pool_enabled" {
  description = "Whether to create a dedicated ingress node pool"
  type        = bool
  default     = true
}

variable "aks_ingress_node_pool" {
  description = "The ingress node pool configuration for AKS (load balancers)"
  type = object({
    name                  = string
    vm_size               = string
    os_disk_size_gb       = number
    enable_auto_scaling   = bool
    min_count             = number
    max_count             = number
    max_pods              = number
    node_taints           = list(string)
    node_labels           = map(string)
    enable_node_public_ip = bool
  })
  default = {
    name                = "ingress"
    vm_size             = "Standard_B2ms" # 2 vCPU, 8GB RAM - better for ingress controllers
    os_disk_size_gb     = 64
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
    max_pods            = 30
    node_taints         = ["ingress=true:NoSchedule"]
    node_labels = {
      "agentpool"                                               = "ingress"
      "node.kubernetes.io/exclude-from-external-load-balancers" = "false"
    }
    enable_node_public_ip = true
  }
}

# AKS Network Configuration
variable "aks_network_plugin" {
  description = "Network plugin for AKS"
  type        = string
  default     = "azure"
}

variable "aks_network_policy" {
  description = "Network policy for AKS"
  type        = string
  default     = null
}

variable "aks_service_cidr" {
  description = "Service CIDR for AKS cluster"
  type        = string
  default     = "10.96.0.0/12"
}

variable "aks_dns_service_ip" {
  description = "DNS service IP for AKS cluster (must be within service_cidr)"
  type        = string
  default     = "10.96.0.10"
}

# AKS Load Balancer Configuration


# AKS Cluster Autoscaler Configuration
variable "aks_enable_cluster_autoscaler" {
  description = "Whether to enable cluster autoscaler"
  type        = bool
  default     = true
}

variable "aks_autoscaler_profile" {
  description = "Cluster autoscaler profile configuration"
  type = object({
    scale_down_delay_after_add       = string
    scale_down_delay_after_delete    = string
    scale_down_delay_after_failure   = string
    scan_interval                    = string
    scale_down_unneeded              = string
    scale_down_unready               = string
    scale_down_utilization_threshold = string
  })
  default = {
    scale_down_delay_after_add       = "15m"
    scale_down_delay_after_delete    = "15s"
    scale_down_delay_after_failure   = "3m"
    scan_interval                    = "10s"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = "0.5"
  }
}

variable "aks_load_balancer_sku" {
  description = "SKU of the load balancer for AKS"
  type        = string
  default     = "standard"
}

variable "aks_outbound_type" {
  description = "Outbound type for AKS cluster"
  type        = string
  default     = "loadBalancer"
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
      name                       = "allow-https-external"
      priority                   = 115
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Allow HTTPS from Internet"
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
      name                       = "allow-http-external"
      priority                   = 125
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Allow HTTP from Internet"
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
      name                       = "allow-ingress-health"
      priority                   = 160
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "10254"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow Ingress Controller health checks"
    },
    {
      name                       = "allow-all-internal"
      priority                   = 170
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow all internal traffic within VNet"
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


