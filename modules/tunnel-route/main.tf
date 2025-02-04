# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

resource "cloudflare_zero_trust_tunnel_route" "route" {
  for_each   = var.module_enabled ? { for index, route in var.routes : route.network => route } : {}
  depends_on = [var.module_depends_on]

  account_id = var.account_id
  tunnel_id  = var.tunnel_id

  network            = each.value.network
  comment            = each.value.comment
  virtual_network_id = each.value.virtual_network_id
}
