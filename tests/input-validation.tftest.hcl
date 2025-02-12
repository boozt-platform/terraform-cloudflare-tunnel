# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

# common variables
variables {
  api_token  = "invalid-token"
  account_id = "fake-account-id"
}

run "tunnel" {
  command = plan

  variables {
    tunnel_name       = "simple-example"
    tunnel_config_src = "invalid"
    tunnel_config = {
      ingress_rule = null
    }
  }

  expect_failures = [
    var.api_token,
    var.tunnel_config_src,
    var.tunnel_config,
  ]
}

run "virtual_network" {
  command = plan

  # Pass an invalid values to test variables validations
  variables {
    virtual_network_name = "fake-virtual-network-name"
  }

  module {
    source = "./modules/virtual-network"
  }

  expect_failures = [
    var.api_token,
  ]
}

run "tunnel_route" {
  command = plan

  # Pass an invalid values to test variables validations
  variables {
    tunnel_id = false
    routes = [
      {
        network = "10.10.1o.0/oooops"
        comment = false
      }
    ]
  }

  module {
    source = "./modules/tunnel-route"
  }

  expect_failures = [
    var.api_token,
    var.routes,
  ]
}
