variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the NSG"
  type        = string
}

variable "name" {
  description = "Name of the Network Security Group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to associate with the NSG"
  type        = string
}

variable "rules" {
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
  description = "Tags to be applied to the NSG"
  type        = map(string)
  default     = {}
} 