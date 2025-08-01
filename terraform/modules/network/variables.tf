# Common Variables
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

# Virtual Network Variables
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

# Subnet Variables
variable "subnet_name" {
  description = "Name of the AKS subnet"
  type        = string
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the AKS subnet"
  type        = list(string)
}

variable "service_endpoints" {
  description = "Service endpoints for the subnet"
  type        = list(string)
  default     = []
}

# Network Security Group Variables
variable "nsg_name" {
  description = "Name of the Network Security Group"
  type        = string
}

variable "security_rules" {
  description = "Map of security rules to be applied to the NSG"
  type = map(object({
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
  default = {}
}

