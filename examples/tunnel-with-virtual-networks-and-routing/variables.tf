# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

variable "api_token" {
  description = "(Optional) The API Token for operations. Alternatively, can be configured using the CLOUDFLARE_API_TOKEN environment variable."
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{40}$", var.api_token))
    error_message = "API Token must be 40 characters long and only contain characters a-z, A-Z, 0-9, hyphens and underscores."
  }
}

variable "account_id" {
  description = "(Required) The account ID for the Cloudflare account."
  type        = string
}
