variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "Location of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resource group"
  type        = map(string)
  default     = {}
} 