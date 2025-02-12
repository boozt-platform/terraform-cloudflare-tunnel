# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

output "routes" {
  description = "The ID of the created tunnel route."
  value = var.module_enabled ? [for route in try(cloudflare_zero_trust_tunnel_route.route, null) : {
    id                 = route.id
    network            = route.network
    virtual_network_id = route.virtual_network_id
    comment            = route.comment
  }] : null
}

output "module_enabled" {
  description = "Whether the module is enabled or not."
  value       = var.module_enabled
}
