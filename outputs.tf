# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

output "tunnel_name" {
  description = "The name of the Cloudflare Tunnel."
  value       = try(cloudflare_zero_trust_tunnel_cloudflared.tunnel[0].name, null)
}

output "tunnel_id" {
  description = "The ID of the Cloudflare Tunnel."
  value       = try(cloudflare_zero_trust_tunnel_cloudflared.tunnel[0].id, null)
}

output "tunnel_secret" {
  description = "The secret of the Cloudflare Tunnel (encoded in base64)."
  value       = local.tunnel_secret
  sensitive   = true
}

output "tunnel_token" {
  description = "The token of the Cloudflare Tunnel."
  value       = try(cloudflare_zero_trust_tunnel_cloudflared.tunnel[0].tunnel_token, null)
  sensitive   = true
}

output "tunnel_cname" {
  description = "Token used by a connector to authenticate and run the tunnel."
  value       = try(cloudflare_zero_trust_tunnel_cloudflared.tunnel[0].cname, null)
}

output "module_enabled" {
  description = "Whether the module is enabled or not."
  value       = var.module_enabled
}
