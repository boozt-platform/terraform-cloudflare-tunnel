# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

# First create a Tunnel
module "tunnel" {
  source      = "github.com/boozt-platform/terraform-cloudflare-tunnel?ref=v1.1.0"
  api_token   = var.api_token
  account_id  = var.account_id
  tunnel_name = "bastion"
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

# Create a Virtual Network
module "virtual_network_01" {
  source     = "github.com/boozt-platform/terraform-cloudflare-tunnel//modules/virtual-network?ref=v1.1.0"
  api_token  = var.api_token
  account_id = var.account_id

  virtual_network_name    = "network-01"
  virtual_network_comment = "This is a test network"
}

# Create a second Virtual Network
module "virtual_network_02" {
  source     = "github.com/boozt-platform/terraform-cloudflare-tunnel//modules/virtual-network?ref=v1.1.0"
  api_token  = var.api_token
  account_id = var.account_id

  virtual_network_name    = "network-02"
  virtual_network_comment = "This is another test network"
}

# Create routes for the Virtual Networks
module "network_01_routes" {
  source     = "github.com/boozt-platform/terraform-cloudflare-tunnel//modules/tunnel-route?ref=v1.1.0"
  api_token  = var.api_token
  account_id = var.account_id

  tunnel_id = module.tunnel.tunnel_id
  routes = [
    {
      network            = "10.10.10.0/24"
      virtual_network_id = module.virtual_network_01.virtual_network_id
      comment            = "Subnet #1 for network 01"
    },
    {
      network            = "10.10.20.0/24"
      virtual_network_id = module.virtual_network_01.virtual_network_id
      comment            = "Subnet #2 for network 01"
    },
  ]
}

# Create routes for the second Virtual Network
module "network_02_routes" {
  source     = "github.com/boozt-platform/terraform-cloudflare-tunnel//modules/tunnel-route?ref=v1.1.0"
  api_token  = var.api_token
  account_id = var.account_id

  tunnel_id = module.tunnel.tunnel_id
  routes = [
    {
      network            = "10.100.10.0/24"
      virtual_network_id = module.virtual_network_02.virtual_network_id
      comment            = "Subnet #1 for network 02"
    }
  ]
}
