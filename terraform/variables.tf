
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
    aks-private = {
      name              = "snet-aks-private"
      address_prefixes  = ["10.0.16.0/20"] # Larger range: 10.0.16.0 - 10.0.31.255
      service_endpoints = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
    }
    aks-public = {
      name              = "snet-aks-public"
      address_prefixes  = ["10.0.32.0/24"] # Non-overlapping: 10.0.32.0 - 10.0.32.255
      service_endpoints = ["Microsoft.ContainerRegistry"]
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

# AKS Node Pools Configuration
variable "aks_node_pool" {
  description = "The default node pool configuration for AKS (system workloads)"
  type = object({
    name                 = string
    vm_size              = string
    os_disk_size_gb      = number
    min_count            = number
    max_count            = number
    max_pods             = number
    node_labels          = map(string)
    auto_scaling_enabled = bool
  })
  default = {
    name                 = "default"
    vm_size              = "Standard_B2s"
    os_disk_size_gb      = 30
    min_count            = 2
    max_count            = 5
    max_pods             = 30
    node_labels          = {}
    auto_scaling_enabled = true
  }
}

# User Node Pool Configuration
variable "aks_user_node_pool" {
  description = "The user node pool configuration for AKS (application workloads)"
  type = object({
    name                 = string
    vm_size              = string
    os_disk_size_gb      = number
    min_count            = number
    max_count            = number
    max_pods             = number
    node_taints          = list(string)
    node_labels          = map(string)
    auto_scaling_enabled = bool
  })
  default = {
    name                 = "userpool"
    vm_size              = "Standard_B2ms" # 2 vCPU, 8GB RAM
    os_disk_size_gb      = 32
    min_count            = 1
    max_count            = 3
    max_pods             = 50
    node_taints          = ["userpool=true:NoSchedule"]
    node_labels          = {}
    auto_scaling_enabled = true
  }
}

variable "aks_ingress_node_pool" {
  description = "The ingress node pool configuration for AKS (load balancers)"
  type = object({
    name                 = string
    vm_size              = string
    os_disk_size_gb      = number
    min_count            = number
    max_count            = number
    max_pods             = number
    node_taints          = list(string)
    node_labels          = map(string)
    auto_scaling_enabled = bool
  })
  default = {
    name                 = "ingress"
    vm_size              = "Standard_B2s" # 2 vCPU, 4GB RAM - smallest compliant size for AKS node pools
    os_disk_size_gb      = 32
    min_count            = 1
    max_count            = 3
    max_pods             = 30
    node_taints          = ["ingress=true:NoSchedule"]
    node_labels          = {}
    auto_scaling_enabled = true
  }
}

# AKS Network Configuration
variable "aks_network_plugin" {
  description = "Network plugin for AKS"
  type        = string
  default     = "azure"
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
    scale_down_delay_after_add       = "5m"
    scale_down_delay_after_delete    = "15s"
    scale_down_delay_after_failure   = "3m"
    scan_interval                    = "5s"
    scale_down_unneeded              = "5m"
    scale_down_unready               = "10m"
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

# NSG Configuration
variable "network_security_groups" {
  description = "Network security group configurations"
  type = map(object({
    name = string
    rules = map(object({
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
  }))
  default = {
    private = {
      name = "nsg-aks-private"
      rules = {
        allow_kubernetes_api = {
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "6443"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow Kubernetes API server access"
        }
        allow_lb_health_probes = {
          priority                   = 300
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "AzureLoadBalancer"
          destination_address_prefix = "*"
          description                = "Allow Azure Load Balancer health probes"
        }
        allow_kubelet = {
          priority                   = 400
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "10250"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow Kubelet API access"
        }
        allow_nodeport_services = {
          priority                   = 500
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "30000-32767"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow NodePort services"
        }
        allow_ingress_health = {
          priority                   = 600
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "10254"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow Ingress Controller health checks"
        }
        allow_pod_communication = {
          priority                   = 700
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1024-65535"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow internal pod TCP communication"
        }
        allow_dns = {
          priority                   = 800
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Udp"
          source_port_range          = "*"
          destination_port_range     = "53"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow DNS traffic"
        }
        allow_udp_communication = {
          priority                   = 900
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Udp"
          source_port_range          = "*"
          destination_port_range     = "1024-65535"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow internal UDP communication"
        }
        allow_outbound_acr = {
          priority                   = 2000
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "AzureContainerRegistry"
          description                = "Allow outbound HTTPS to ACR"
        }
        allow_outbound_keyvault = {
          priority                   = 2100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "AzureKeyVault"
          description                = "Allow outbound HTTPS to KeyVault"
        }
      }
    }
    public = {
      name = "nsg-aks-public"
      rules = {
        allow_internet_http = {
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "Internet"
          destination_address_prefix = "*"
          description                = "Allow HTTP traffic from internet"
        }
        allow_internet_https = {
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "Internet"
          destination_address_prefix = "*"
          description                = "Allow HTTPS traffic from internet"
        }
        allow_lb_health_probes = {
          priority                   = 300
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "AzureLoadBalancer"
          destination_address_prefix = "*"
          description                = "Allow Azure Load Balancer health probes"
        }
        allow_kubernetes_api = {
          priority                   = 400
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "6443"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow Kubernetes API server access"
        }
        allow_kubelet = {
          priority                   = 500
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "10250"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow Kubelet API access"
        }
        allow_nodeport_services = {
          priority                   = 600
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "30000-32767"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow NodePort services"
        }
        allow_ingress_health = {
          priority                   = 700
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "10254"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow Ingress Controller health checks"
        }
        allow_pod_communication = {
          priority                   = 800
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1024-65535"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow internal pod TCP communication"
        }
        allow_dns = {
          priority                   = 900
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Udp"
          source_port_range          = "*"
          destination_port_range     = "53"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow DNS traffic"
        }
        allow_udp_communication = {
          priority                   = 1000
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Udp"
          source_port_range          = "*"
          destination_port_range     = "1024-65535"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
          description                = "Allow internal UDP communication"
        }
      }
    }
  }
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

# Role Assignment Defaults
variable "role_assignment_defaults" {
  description = "Default values for role assignments"
  type = object({
    description = string
  })
  default = {
    description = null
  }
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

