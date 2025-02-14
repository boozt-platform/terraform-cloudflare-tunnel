# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

module "cloudflare_tunnel" {
  source      = "github.com/boozt-platform/terraform-cloudflare-tunnel?ref=v1.1.0"
  tunnel_name = "my-8080-service-on-example-com"
  account_id  = var.account_id
  api_token   = var.api_token

  tunnel_config = {
    ingress_rule = [
      {
        hostname = "example.com"
        service  = "http://localhost:8080"
      },
      # at the end of the list, add a rule that will catch-all 404 responses
      {
        service = "http_status:404"
      },
    ]
  }
}
