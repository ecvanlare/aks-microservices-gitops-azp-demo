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
variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    name              = string
    address_prefixes  = list(string)
    service_endpoints = list(string)
  }))
}

# Network Security Group Variables
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
}

