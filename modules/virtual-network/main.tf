# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

resource "cloudflare_zero_trust_tunnel_virtual_network" "virtual_network" {
  count      = var.module_enabled ? 1 : 0
  depends_on = [var.module_depends_on]

  account_id         = var.account_id
  name               = var.virtual_network_name
  comment            = var.virtual_network_comment
  is_default_network = var.virtual_network_is_default_network
}
