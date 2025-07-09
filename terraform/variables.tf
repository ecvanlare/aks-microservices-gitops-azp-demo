# Resource Group Variables
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "online-boutique"
}

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
  description = "Name of the Virtual Network"
  type        = string
  default     = "vnet-online-boutique"
}

variable "nsg_name" {
  description = "Name of the Network Security Group"
  type        = string
  default     = "nsg-aks"
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

variable "acr_admin_enabled" {
  description = "Enable admin access to the container registry"
  type        = bool
  default     = false
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
    vm_size             = "Standard_B1ms" # 1 vCPU, 2GB RAM - sufficient for system workloads + Redis
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
    vm_size             = "Standard_B2ms" # 2 vCPU, 8GB RAM - sufficient for 12 microservices
    os_disk_size_gb     = 32
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
    vm_size             = "Standard_B1ms" # 1 vCPU, 2GB RAM - sufficient for ingress controllers
    os_disk_size_gb     = 32
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
variable "aks_max_pods_per_node" {
  description = "Maximum number of pods per node"
  type        = number
  default     = 30
  validation {
    condition     = var.aks_max_pods_per_node >= 10 && var.aks_max_pods_per_node <= 250
    error_message = "Max pods per node must be between 10 and 250."
  }
}

# AKS Cluster Autoscaler Configuration
variable "aks_enable_cluster_autoscaler" {
  description = "Whether to enable cluster autoscaler"
  type        = bool
  default     = true
}

variable "aks_autoscaler_profile" {
  description = "Autoscaler profile configuration for AKS"
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

variable "aks_timeouts" {
  description = "Timeouts for AKS cluster operations"
  type = object({
    create = string
    update = string
    delete = string
  })
  default = {
    create = "60m"
    update = "60m"
    delete = "60m"
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

# Key Vault RBAC Role Names
variable "keyvault_admin_role" {
  description = "Azure RBAC role for admin group in Key Vault"
  type        = string
  default     = "Key Vault Administrator"
}

variable "keyvault_secrets_officer_role" {
  description = "Azure RBAC role for developer group in Key Vault"
  type        = string
  default     = "Key Vault Secrets Officer"
}

variable "keyvault_reader_role" {
  description = "Azure RBAC role for viewer group in Key Vault"
  type        = string
  default     = "Key Vault Reader"
}

# Key Vault Configuration Variables
variable "keyvault_soft_delete_retention_days" {
  description = "Soft delete retention days for Key Vault"
  type        = number
  default     = 7
}

variable "keyvault_purge_protection_enabled" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = false
}

variable "keyvault_sku_name" {
  description = "SKU name for Key Vault"
  type        = string
  default     = "standard"
}

variable "keyvault_network_acls" {
  description = "Network ACLs configuration for Key Vault"
  type = object({
    default_action = string
    bypass         = string
  })
  default = {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

variable "keyvault_terraform_role_name" {
  description = "Azure RBAC role name for Terraform access to Key Vault"
  type        = string
  default     = "Key Vault Administrator"
}

variable "keyvault_aks_role_name" {
  description = "Azure RBAC role name for AKS access to Key Vault"
  type        = string
  default     = "Key Vault Secrets User"
}

# Identity Role Names
variable "acr_pull_role_name" {
  description = "Azure RBAC role name for ACR pull access"
  type        = string
  default     = "AcrPull"
}

variable "acr_push_role_name" {
  description = "Azure RBAC role name for ACR push access"
  type        = string
  default     = "AcrPush"
}

variable "network_contributor_role_name" {
  description = "Azure RBAC role name for network contributor access"
  type        = string
  default     = "Network Contributor"
}

# Identity Module Variables
variable "role_assignment_description" {
  description = "Description for role assignments"
  type        = string
  default     = null
}

variable "role_assignment_condition" {
  description = "Condition for role assignments"
  type        = string
  default     = null
}

variable "role_assignment_condition_version" {
  description = "Condition version for role assignments"
  type        = string
  default     = "2.0"
}

variable "role_assignment_skip_existing_check" {
  description = "Whether to skip checking if role assignment already exists"
  type        = bool
  default     = false
}

# Note: Secrets are managed via Azure Portal
# Add these secrets manually in the Key Vault after deployment:
# - cloudflare-api-token
# - cloudflare-zone-id  
# - domain-name
# - cert-manager-email




