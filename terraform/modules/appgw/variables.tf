variable "name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for the Application Gateway"
  type        = string
}

variable "public_ip_address_id" {
  description = "ID of the public IP address for the Application Gateway"
  type        = string
  default     = null
}

variable "sku" {
  description = "SKU of the Application Gateway"
  type = object({
    name     = string
    tier     = string
    capacity = number
  })
}

variable "frontend_ip_configuration" {
  description = "Frontend IP configuration for Application Gateway"
  type = object({
    name = string
  })
}

variable "backend_address_pools" {
  description = "Backend address pools for Application Gateway"
  type = list(object({
    name  = string
    fqdns = list(string)
  }))
}

variable "http_listeners" {
  description = "HTTP listeners for Application Gateway"
  type = list(object({
    name                           = string
    frontend_ip_configuration_name = string
    frontend_port_name             = string
    protocol                       = string
    host_name                      = string
  }))
}

variable "request_routing_rules" {
  description = "Request routing rules for Application Gateway"
  type = list(object({
    name                       = string
    rule_type                  = string
    http_listener_name         = string
    backend_address_pool_name  = string
    backend_http_settings_name = string
  }))
}

variable "tags" {
  description = "Tags to apply to the Application Gateway"
  type        = map(string)
  default     = {}
} 