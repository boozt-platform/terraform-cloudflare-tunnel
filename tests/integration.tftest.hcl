# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

run "tunnel" {
  command = apply

  variables {
    tunnel_name = "simple-example"
    tunnel_config = {
      ingress_rule = [
        {
          service = "bastion"
          origin_request = {
            bastion_mode = true
          }
        }
      ]
    }
  }

  assert {
    condition     = output.tunnel_id != ""
    error_message = "The Cloudflare tunnel ID is empty."
  }

  assert {
    condition     = output.tunnel_secret != ""
    error_message = "The Cloudflare tunnel secret is empty."
  }

  assert {
    condition     = output.tunnel_token != base64decode(output.tunnel_secret)
    error_message = "The Cloudflare tunnel token not matched of the generated token."
  }

  assert {
    condition     = output.tunnel_cname != ""
    error_message = "The Cloudflare tunnel cname is empty."
  }
}

run "virtual_network" {
  command = apply

  variables {
    virtual_network_name               = "${run.tunnel.tunnel_name}-virtual-network"
    virtual_network_comment            = "${run.tunnel.tunnel_name} description"
    virtual_network_is_default_network = false
  }

  module {
    source = "./modules/virtual-network"
  }

  assert {
    condition     = output.virtual_network_name == var.virtual_network_name
    error_message = "The Cloudflare virtual network name does not match."
  }

  assert {
    condition     = length(output.virtual_network_id) > 0
    error_message = "The Cloudflare virtual network ID is empty."
  }

  assert {
    condition     = cloudflare_zero_trust_tunnel_virtual_network.virtual_network[0].is_default_network == false
    error_message = "The Cloudflare virtual network is not the default network."
  }
}

run "tunnel_route" {
  command = apply

  variables {
    tunnel_id = run.tunnel.tunnel_id
    routes = [
      {
        network            = "10.20.10.0/24"
        comment            = "Test route 1"
        virtual_network_id = run.virtual_network.virtual_network_id
      },
      {
        network = "10.30.10.0/24"
        comment = "Test route 2"
      }
    ]
  }

  module {
    source = "./modules/tunnel-route"
  }

  # check if we have at least two routes
  assert {
    condition     = length(cloudflare_zero_trust_tunnel_route.route) == 2
    error_message = "The Cloudflare tunnel routes are not two."
  }

  # check if the first route network is valid CIDR
  assert {
    condition     = can(cidrsubnet(output.routes[0].network, 0, 0))
    error_message = "The Cloudflare tunnel route network is not a valid CIDR."
  }

  # check if the second route network is valid CIDR
  assert {
    condition     = can(cidrsubnet(output.routes[1].network, 0, 0))
    error_message = "The Cloudflare tunnel route network is not a valid CIDR."
  }
}
