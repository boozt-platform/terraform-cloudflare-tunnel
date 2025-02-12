# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

# common variables
variables {
  api_token  = "0123456789012345678901234567890123456789"
  account_id = "fake-account-id"
}

run "tunnel" {
  command = plan

  variables {
    tunnel_name = "simple-example"
    tunnel_config = {
      ingress_rule = [
        {
          service = "bastion"
          origin_request = {
            bastion_mode = true
          }
        },
      ]
    }
  }

  assert {
    condition     = cloudflare_zero_trust_tunnel_cloudflared.tunnel[0].name == "tf-tunnel-${var.tunnel_name}"
    error_message = "${cloudflare_zero_trust_tunnel_cloudflared.tunnel[0].name} does not match the expected name."
  }

  assert {
    condition     = cloudflare_zero_trust_tunnel_cloudflared.tunnel[0].account_id == var.account_id
    error_message = "The Cloudflare account id does not match."
  }

  assert {
    condition     = cloudflare_zero_trust_tunnel_cloudflared.tunnel[0].config_src == "cloudflare"
    error_message = "The Cloudflare tunnel config source does not match."
  }

  assert {
    condition     = cloudflare_zero_trust_tunnel_cloudflared_config.tunnel_config[0].config[0].ingress_rule[0].service == var.tunnel_config.ingress_rule[0].service
    error_message = "The Cloudflare tunnel ingress rule service does not match."
  }

  assert {
    condition     = cloudflare_zero_trust_tunnel_cloudflared_config.tunnel_config[0].config[0].ingress_rule[0].origin_request[0].bastion_mode == var.tunnel_config.ingress_rule[0].origin_request.bastion_mode
    error_message = "The Cloudflare tunnel ingress rule origin request bastion mode does not match."
  }
}

run "virtual_network" {
  command = plan

  variables {
    virtual_network_name               = "fake-virtual-network-name"
    virtual_network_comment            = "fake-virtual-network-comment"
    virtual_network_is_default_network = true
  }

  module {
    source = "./modules/virtual-network"
  }

  assert {
    condition     = cloudflare_zero_trust_tunnel_virtual_network.virtual_network[0].name == var.virtual_network_name
    error_message = "The Cloudflare virtual network name does not match."
  }

  assert {
    condition     = cloudflare_zero_trust_tunnel_virtual_network.virtual_network[0].comment == var.virtual_network_comment
    error_message = "The Cloudflare virtual network comment does not match."
  }

  assert {
    condition     = cloudflare_zero_trust_tunnel_virtual_network.virtual_network[0].is_default_network == var.virtual_network_is_default_network
    error_message = "The Cloudflare virtual network is not the default network."
  }
}

run "tunnel_route" {
  command = plan

  variables {
    tunnel_id = "fake-tunnel-id"
    routes = [
      {
        network            = "10.10.10.0/24"
        virtual_network_id = "fake-virtual-network-id"
        comment            = "Test route"
      },
      {
        network            = "10.10.11.0/24"
        virtual_network_id = "fake-virtual-network-id-2"
        comment            = "Test route 2"
      },
    ]
  }

  module {
    source = "./modules/tunnel-route"
  }

  assert {
    condition     = cloudflare_zero_trust_tunnel_route.route["10.10.10.0/24"].network == var.routes[0].network
    error_message = "The Cloudflare tunnel route network does not match."
  }

  assert {
    condition     = cloudflare_zero_trust_tunnel_route.route["10.10.10.0/24"].virtual_network_id == var.routes[0].virtual_network_id
    error_message = "The Cloudflare tunnel route virtual network id does not match."
  }

  assert {
    condition     = cloudflare_zero_trust_tunnel_route.route["10.10.10.0/24"].comment == var.routes[0].comment
    error_message = "The Cloudflare tunnel route comment does not match."
  }

  assert {
    condition     = length(cloudflare_zero_trust_tunnel_route.route) > 1
    error_message = "The Cloudflare tunnel routes are not more than one."
  }
}

run "tunnel_disabled" {
  command = plan

  variables {
    tunnel_name = "simple-example"
    tunnel_config = {
      ingress_rule = [
        {
          service = "bastion"
          origin_request = {
            bastion_mode = true
          }
        },
      ]
    }
    module_enabled = false
  }

  assert {
    condition     = try(cloudflare_zero_trust_tunnel_cloudflared.tunnel[0], null) == null
    error_message = "The Cloudflare tunnel is not null."
  }
}

run "tunnel_route_disabled" {
  command = plan

  variables {
    tunnel_id = "fake-tunnel-id"
    routes = [
      {
        network = "10.10.10.0/24"
      }
    ]
    module_enabled = false
  }

  module {
    source = "./modules/tunnel-route"
  }

  assert {
    condition     = try(cloudflare_zero_trust_tunnel_route.route[0], null) == null
    error_message = "The Cloudflare tunnel route is not null."
  }
}

run "virtual_network_disabled" {
  command = plan

  variables {
    virtual_network_name               = "fake-virtual-network-name"
    virtual_network_comment            = "fake-virtual-network-comment"
    virtual_network_is_default_network = true
    module_enabled                     = false
  }

  module {
    source = "./modules/virtual-network"
  }

  assert {
    condition     = try(cloudflare_zero_trust_tunnel_virtual_network.virtual_network[0], null) == null
    error_message = "The Cloudflare virtual network is not null."
  }
}
