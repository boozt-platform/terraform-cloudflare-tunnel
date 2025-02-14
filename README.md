<!-- BEGIN_TF_DOCS -->
<!-- markdownlint-disable -->
[<img src="https://raw.githubusercontent.com/boozt-platform/branding/main/assets/img/platform-logo.png" width="350"/>][homepage]

[![GitHub Tag (latest SemVer)](https://img.shields.io/github/v/tag/boozt-platform/terraform-cloudflare-tunnel.svg?label=latest&sort=semver)][releases]
[![license](https://img.shields.io/badge/license-mit-brightgreen.svg)][license]
<!-- markdownlint-restore -->

# terraform-cloudflare-tunnel

Terraform configurations to manage and deploy Cloudflare Tunnels, enabling
secure and seamless connectivity to private networks or applications. It
includes a modular structure, allowing users to customize and extend
functionality for various platforms and environments.

## Table of Contents

- [Modules](#modules)
- [How to Use It](#how-to-use-it)
- [Examples](#examples)
  - [Tunnel example with GSM and token verification.](#tunnel-example-with-gsm-and-token-verification)
- [About Boozt](#about-boozt)
- [Reporting Issues](#reporting-issues)
- [Contributing](#contributing)
- [License](#license)

## Modules

- [CloudFlare Tunnel](#how-to-use-it)
- [Cloudflare Tunnel Routes](./modules/tunnel-route/)
- [Cloudflare Virtual Network](./modules/virtual-network/)

## How to Use it

This Terraform configuration provisions a Cloudflare Tunnel to securely
expose a local HTTP service running on port 8080 (localhost:8080) to the
public internet under the hostname example.com.

<!-- markdownlint-disable -->
```hcl
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
```
<!-- markdownlint-restore -->

## Examples

### Tunnel example with GSM and token verification

This Terraform configuration sets up a Cloudflare Tunnel in bastion mode,
securely stores the tunnel token in Google Cloud Secret Manager, and
validates the tunnel token to ensure it functions correctly.

<!-- markdownlint-disable -->
```hcl
# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

# This example creates a Cloudflare Tunnel with a bastion mode enabled.
module "tunnel" {
  source      = "github.com/boozt-platform/terraform-cloudflare-tunnel"
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

# Create a secret in GCP Secret Manager and store the tunnel secret in it
module "tunnel_secret" {
  source     = "GoogleCloudPlatform/secret-manager/google"
  version    = "~> 0.7"
  project_id = var.project_id
  secrets = [
    {
      name        = "cf-tunnel-bastion-access-token"
      secret_data = module.tunnel.tunnel_token
    },
  ]
}

# Get the secret from GCP Secret Manager
# We are testing if the secret is created and we can retrieve it
data "google_secret_manager_secret_version" "tunnel_secret" {
  # secret = one(module.tunnel_secret.secret_names)
  secret     = "cf-tunnel-bastion-access-token"
  project    = var.project_id
  depends_on = [module.tunnel_secret]
}

# Validate the tunnel token by running cloudflared tunnel command
resource "null_resource" "validate_tunnel_token" {
  provisioner "local-exec" {
    command = <<EOT
      source .secrets
      # Run cloudflared in the background with timeout
      timeout 5s cloudflared tunnel --loglevel debug run --bastion --token ${data.google_secret_manager_secret_version.tunnel_secret.secret_data} &

      # Get process ID (PID) of cloudflared
      PID=$!

      # Wait a few seconds for successful connection
      sleep 5

      # Check logs for a successful connection message
      if ps -p $PID > /dev/null; then
        echo "Tunnel is running successfully. Killing process..."
        kill $PID
      else
        echo "Tunnel failed to start."
        exit 1
      fi
    EOT
  }
}
```

### Tunnel with Virtual Networks and Routing

This Terraform configuration creates a Cloudflare Tunnel, provisions two
virtual networks, and defines routing rules for private IP subnets within
Cloudflare Zero Trust. This setup allows secure access to internal networks
via Cloudflare Tunnel.

```hcl
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
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Required) The account ID for the Cloudflare account. | `string` | n/a | yes |
| <a name="input_api_token"></a> [api\_token](#input\_api\_token) | (Optional) The API Token for operations. Alternatively, can be configured using the CLOUDFLARE\_API\_TOKEN environment variable. | `string` | `null` | no |
| <a name="input_module_depends_on"></a> [module\_depends\_on](#input\_module\_depends\_on) | (Optional) A list of external resources the module depends\_on. | `any` | `[]` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Whether to create resources within the module or not. | `bool` | `true` | no |
| <a name="input_tunnel_config"></a> [tunnel\_config](#input\_tunnel\_config) | (Required) The configuration for the Cloudflare Tunnel. | <pre>object({<br/>    warp_routing = optional(bool, false)<br/><br/>    origin_request = optional(object({<br/>      connect_timeout          = optional(string, "30s")<br/>      tls_timeout              = optional(string, "10s")<br/>      tcp_keep_alive           = optional(string, "30s")<br/>      no_happy_eyeballs        = optional(bool, false)<br/>      keep_alive_connections   = optional(number, 100)<br/>      keep_alive_timeout       = optional(string, "1m30s")<br/>      http_host_header         = optional(string, "")<br/>      origin_server_name       = optional(string, "")<br/>      ca_pool                  = optional(string, "")<br/>      no_tls_verify            = optional(bool, false)<br/>      disable_chunked_encoding = optional(bool, false)<br/>      bastion_mode             = optional(bool, false)<br/>      http2_origin             = optional(bool, false)<br/>      proxy_address            = optional(string, "127.0.0.1")<br/>      proxy_port               = optional(string, "0")<br/>      proxy_type               = optional(string, "")<br/><br/>      ip_rules = optional(list(object({<br/>        prefix = optional(string)<br/>        ports  = optional(list(number))<br/>        allow  = optional(bool)<br/>      })))<br/><br/>      access = optional(object({<br/>        required  = optional(bool)<br/>        team_name = optional(string)<br/>        aud_tag   = optional(set(string))<br/>      }))<br/>    }))<br/><br/>    ingress_rule = list(object({<br/>      hostname = optional(string)<br/>      path     = optional(string)<br/>      service  = string<br/><br/>      origin_request = optional(object({<br/>        connect_timeout          = optional(string, "30s")<br/>        tls_timeout              = optional(string, "10s")<br/>        tcp_keep_alive           = optional(string, "30s")<br/>        no_happy_eyeballs        = optional(bool, false)<br/>        keep_alive_connections   = optional(number, 100)<br/>        keep_alive_timeout       = optional(string, "1m30s")<br/>        http_host_header         = optional(string, "")<br/>        origin_server_name       = optional(string, "")<br/>        ca_pool                  = optional(string, "")<br/>        no_tls_verify            = optional(bool, false)<br/>        disable_chunked_encoding = optional(bool, false)<br/>        bastion_mode             = optional(bool, false)<br/>        http2_origin             = optional(bool, false)<br/>        proxy_address            = optional(string, "127.0.0.1")<br/>        proxy_port               = optional(string, "0")<br/>        proxy_type               = optional(string, "")<br/><br/>        ip_rules = optional(list(object({<br/>          prefix = optional(string)<br/>          ports  = optional(list(number))<br/>          allow  = optional(bool)<br/>        })))<br/><br/>        access = optional(object({<br/>          required  = optional(bool)<br/>          team_name = optional(string)<br/>          aud_tag   = optional(set(string))<br/>        }))<br/>      }))<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_tunnel_config_src"></a> [tunnel\_config\_src](#input\_tunnel\_config\_src) | (Optional) Indicates if this is a locally or remotely configured tunnel. If local, manage the tunnel using a YAML file on the origin machine. If cloudflare, manage the tunnel on the Zero Trust dashboard or using tunnel\_config, tunnel\_route or tunnel\_virtual\_network resources. Available values: local, cloudflare. | `string` | `"cloudflare"` | no |
| <a name="input_tunnel_name"></a> [tunnel\_name](#input\_tunnel\_name) | (Required) The name of the Cloudflare Tunnel. | `string` | n/a | yes |
| <a name="input_tunnel_prefix_name"></a> [tunnel\_prefix\_name](#input\_tunnel\_prefix\_name) | (Optional) The prefix name of the Cloudflare Tunnel. | `string` | `"tf-tunnel"` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_module_enabled"></a> [module\_enabled](#output\_module\_enabled) | Whether the module is enabled or not. |
| <a name="output_tunnel_cname"></a> [tunnel\_cname](#output\_tunnel\_cname) | Token used by a connector to authenticate and run the tunnel. |
| <a name="output_tunnel_id"></a> [tunnel\_id](#output\_tunnel\_id) | The ID of the Cloudflare Tunnel. |
| <a name="output_tunnel_name"></a> [tunnel\_name](#output\_tunnel\_name) | The name of the Cloudflare Tunnel. |
| <a name="output_tunnel_token"></a> [tunnel\_token](#output\_tunnel\_token) | The token of the Cloudflare Tunnel. |
<!-- markdownlint-restore -->

<!-- markdownlint-disable first-line-h1 -->
## About Boozt

Boozt is a leading and fast-growing Nordic technology company selling fashion
and lifestyle online mainly through its multi-brand webstore [Boozt.com][boozt]
and [Booztlet.com][booztlet].

The company is focused on using cutting-edge, in-house developed technology to
curate the best possible customer experience.

With offices in Sweden, Denmark, Lithuania and Poland, we pride ourselves in
having a diverse team, consisting of 1100+ employees and 38 nationalities.

See our [Medium][blog] blog page for technology-focused articles. Would you
like to make your mark by working with us at Boozt? Take a look at our
[latest hiring opportunities][careers].

## Reporting Issues

Please provide a clear and concise description of the problem or the feature
you're missing along with any relevant context or screenshots.

Check existing issues before reporting to avoid duplicates.

Please follow the [Issue Reporting Guidelines][issues] before opening a new issue.

## Contributing

Contributions are highly valued and very welcome! For the process of reviewing
changes, we use [Pull Requests][pull-request]. For a detailed information
please follow the [Contribution Guidelines][contributing]

## License

[![license](https://img.shields.io/badge/license-mit-brightgreen.svg)][license]

This project is licensed under the MIT. Please see [LICENSE][license] for
full details.

<!-- markdownlint-disable link-image-reference-definitions -->
[homepage]: https://github.com/boozt-platform/terraform-cloudflare-tunnel
[releases]: https://github.com/boozt-platform/terraform-cloudflare-tunnel/releases
[issues]: https://github.com/boozt-platform/terraform-cloudflare-tunnel/issues
[pull-request]: https://github.com/boozt-platform/terraform-cloudflare-tunnel/pulls
[contributing]: ./docs/CONTRIBUTING.md
[license]: ./LICENSE
[boozt]: https://www.boozt.com/
[booztlet]: https://www.booztlet.com/
[blog]: https://medium.com/boozt-tech
[careers]: https://careers.booztgroup.com/
<!-- markdownlint-disable single-trailing-newline -->
<!-- END_TF_DOCS -->