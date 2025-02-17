# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

variable "api_token" {
  description = "(Optional) The API Token for operations. Alternatively, can be configured using the CLOUDFLARE_API_TOKEN environment variable."
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.api_token == null || can(regex("^[a-zA-Z0-9_-]{40}$", var.api_token))
    error_message = "API Token must be 40 characters long and only contain characters a-z, A-Z, 0-9, hyphens and underscores."
  }
}

variable "account_id" {
  description = "(Required) The account identifier to target for the resource. Modifying this attribute will force creation of a new resource."
  type        = string
}

variable "virtual_network_name" {
  description = "(Required) A user-friendly name chosen when the virtual network is created."
  type        = string
}

variable "virtual_network_comment" {
  description = "(Optional) Description of the tunnel virtual network."
  type        = string
  default     = null
}

variable "virtual_network_is_default_network" {
  description = "(Optional) Whether this virtual network is the default one for the account."
  type        = bool
  default     = false
}

variable "module_enabled" {
  type        = bool
  description = "(Optional) Whether to create resources within the module or not."
  default     = true
}

variable "module_depends_on" {
  type        = any
  description = "(Optional) A list of external resources the module depends_on."
  default     = []
}
