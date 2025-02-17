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

variable "tunnel_id" {
  description = "(Required) The ID of the tunnel that will service the tunnel route."
  type        = string
}

variable "routes" {
  description = "(Required) A list of tunnel network routes to create."
  type = list(object({
    # The IPv4 or IPv6 network that should use this tunnel route, in CIDR notation.
    network = string
    # The ID of the virtual network for which this route is being added; uses the default
    # virtual network of the account if none is provided. Modifying this attribute will force
    # creation of a new resource.
    virtual_network_id = optional(string)
    # A description of the tunnel route.
    comment = optional(string)
  }))

  validation {
    condition     = length(var.routes) > 0
    error_message = "At least one tunnel route must be defined."
  }

  # Validate that all routes are valid CIDRs
  validation {
    condition = length([
      for o in var.routes : o if can(cidrsubnet(o.network, 0, 0))
    ]) == length(var.routes)
    error_message = "Tunnel route network is not a valid CIDR."
  }
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
