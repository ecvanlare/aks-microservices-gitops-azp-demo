variable "scope" {
  description = "The scope at which the role assignment is created (e.g., ACR ID)"
  type        = string
}

variable "role_definition_name" {
  description = "The name of the role definition (e.g., AcrPull, AcrPush)"
  type        = string
}

variable "principal_id" {
  description = "The ID of the principal (managed identity) to assign the role to"
  type        = string
}

variable "description" {
  description = "A description of the role assignment."
  type        = string
  default     = null
}

variable "condition" {
  description = "The condition which limits the resources that the role can be assigned to."
  type        = string
  default     = null
}

variable "condition_version" {
  description = "The version of the condition syntax."
  type        = string
  default     = "2.0"
}

variable "skip_existing_check" {
  description = "Whether to skip checking if the role assignment already exists."
  type        = bool
  default     = false
} 