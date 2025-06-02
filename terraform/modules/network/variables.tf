variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the network resources"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "name" {
  description = "Name of the subnet"
  type        = string
}

variable "address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
}

variable "service_endpoints" {
  description = "Service endpoints for the subnet"
  type        = list(string)
  default     = []
}

variable "aks_nsg_name" {
  description = "Name of the AKS Network Security Group"
  type        = string
}

variable "security_rules" {
  description = "List of security rules to be applied to the NSG"
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
  }))
  default = []
}

variable "tags" {
  description = "Tags to be applied to all network resources"
  type        = map(string)
  default     = {}
} 