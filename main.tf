# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

locals {
  tunnel_secret = try(base64encode(random_password.tunnel_secret[0].result), null)
  tunnel_name   = "${var.tunnel_prefix_name}-${var.tunnel_name}"
}

# TODO: change resource with ephemeral resource once it's released:
# https://github.com/hashicorp/terraform-provider-random/pull/625
resource "random_password" "tunnel_secret" {
  count  = var.module_enabled ? 1 : 0
  length = 64

  keepers = {
    tunnel_name = local.tunnel_name
  }

  depends_on = [var.module_depends_on]
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel" {
  count      = var.module_enabled ? 1 : 0
  depends_on = [var.module_depends_on]

  account_id = var.account_id
  name       = local.tunnel_name
  secret     = local.tunnel_secret
  config_src = var.tunnel_config_src
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel_config" {
  count      = var.module_enabled ? 1 : 0
  depends_on = [var.module_depends_on]

  account_id = var.account_id
  tunnel_id  = try(cloudflare_zero_trust_tunnel_cloudflared.tunnel[0].id, null)

  dynamic "config" {
    for_each = [var.tunnel_config]

    content {
      warp_routing {
        enabled = config.value.warp_routing
      }

      dynamic "origin_request" {
        for_each = config.value.origin_request != null ? [config.value.origin_request] : []

        content {
          connect_timeout          = origin_request.value.connect_timeout
          tls_timeout              = origin_request.value.tls_timeout
          tcp_keep_alive           = origin_request.value.tcp_keep_alive
          no_happy_eyeballs        = origin_request.value.no_happy_eyeballs
          keep_alive_connections   = origin_request.value.keep_alive_connections
          keep_alive_timeout       = origin_request.value.keep_alive_timeout
          http_host_header         = origin_request.value.http_host_header
          origin_server_name       = origin_request.value.origin_server_name
          ca_pool                  = origin_request.value.ca_pool
          no_tls_verify            = origin_request.value.no_tls_verify
          disable_chunked_encoding = origin_request.value.disable_chunked_encoding
          bastion_mode             = origin_request.value.bastion_mode
          proxy_address            = origin_request.value.proxy_address
          proxy_port               = origin_request.value.proxy_port
          proxy_type               = origin_request.value.proxy_type

          dynamic "ip_rules" {
            for_each = origin_request.value.ip_rules != null ? origin_request.value.ip_rules : []
            content {
              prefix = ip_rules.value.prefix
              ports  = ip_rules.value.ports
              allow  = ip_rules.value.allow
            }
          }

          dynamic "access" {
            for_each = origin_request.value.access != null ? [origin_request.value.access] : []
            content {
              required  = access.value.required
              team_name = access.value.team_name
              aud_tag   = access.value.aud_tag
            }
          }
        }
      }

      dynamic "ingress_rule" {
        for_each = config.value.ingress_rule

        content {
          hostname = ingress_rule.value.hostname
          path     = ingress_rule.value.path
          service  = ingress_rule.value.service

          dynamic "origin_request" {
            for_each = ingress_rule.value.origin_request != null ? [ingress_rule.value.origin_request] : []

            content {
              connect_timeout          = origin_request.value.connect_timeout
              tls_timeout              = origin_request.value.tls_timeout
              tcp_keep_alive           = origin_request.value.tcp_keep_alive
              no_happy_eyeballs        = origin_request.value.no_happy_eyeballs
              keep_alive_connections   = origin_request.value.keep_alive_connections
              keep_alive_timeout       = origin_request.value.keep_alive_timeout
              http_host_header         = origin_request.value.http_host_header
              origin_server_name       = origin_request.value.origin_server_name
              ca_pool                  = origin_request.value.ca_pool
              no_tls_verify            = origin_request.value.no_tls_verify
              disable_chunked_encoding = origin_request.value.disable_chunked_encoding
              bastion_mode             = origin_request.value.bastion_mode
              proxy_address            = origin_request.value.proxy_address
              proxy_port               = origin_request.value.proxy_port
              proxy_type               = origin_request.value.proxy_type

              dynamic "ip_rules" {
                for_each = origin_request.value.ip_rules != null ? [origin_request.value.ip_rules] : []
                content {
                  prefix = ip_rules.value.prefix
                  ports  = ip_rules.value.ports
                  allow  = ip_rules.value.allow
                }
              }

              dynamic "access" {
                for_each = origin_request.value.access != null ? [origin_request.value.access] : []
                content {
                  required  = access.value.required
                  team_name = access.value.team_name
                  aud_tag   = access.value.aud_tag
                }
              }
            }
          }
        }
      }
    }
  }
}
