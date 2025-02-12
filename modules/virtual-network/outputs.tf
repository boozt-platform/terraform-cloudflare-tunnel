# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

output "virtual_network_id" {
  description = "The ID of the created virtual network."
  value       = try(cloudflare_zero_trust_tunnel_virtual_network.virtual_network[0].id, null)
}

output "virtual_network_name" {
  description = "The name of the created virtual network."
  value       = var.module_enabled ? var.virtual_network_name : null
}

output "module_enabled" {
  description = "Whether the module is enabled or not."
  value       = var.module_enabled
}
