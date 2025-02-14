# terraform-cloudflare-tunnel/tunnel-route

The tunnel-route module in the terraform-cloudflare-tunnel repository is
designed to define and manage routing configurations for Cloudflare Tunnels
within a Zero Trust architecture. It enables the association of specific
private IP address ranges (subnets) with designated Cloudflare Virtual
Networks, facilitating secure and efficient traffic routing through the
tunnels.

```hcl
module "network_routes" {
  source     = "github.com/boozt-platform/terraform-cloudflare-tunnel//modules/tunnel-route"
  api_token  = var.api_token
  account_id = var.account_id
  tunnel_id  = var.tunnel_id

  routes = [
    {
      network            = "10.10.10.0/24"
      virtual_network_id = var.virtual_network_id_1
      comment            = "Subnet #1 for virtual network 1"
    },
    {
      network            = "10.10.20.0/24"
      virtual_network_id = var.virtual_network_id_2
      comment            = "Subnet #2 for virtual network 2"
    },
  ]
}
```
<!-- markdownlint-disable -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | < 5 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | < 5 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Required) The account identifier to target for the resource. Modifying this attribute will force creation of a new resource. | `string` | n/a | yes |
| <a name="input_api_token"></a> [api\_token](#input\_api\_token) | (Optional) The API Token for operations. Alternatively, can be configured using the CLOUDFLARE\_API\_TOKEN environment variable. | `string` | `null` | no |
| <a name="input_module_depends_on"></a> [module\_depends\_on](#input\_module\_depends\_on) | (Optional) A list of external resources the module depends\_on. | `any` | `[]` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Whether to create resources within the module or not. | `bool` | `true` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | (Required) A list of tunnel network routes to create. | <pre>list(object({<br/>    # The IPv4 or IPv6 network that should use this tunnel route, in CIDR notation.<br/>    network = string<br/>    # The ID of the virtual network for which this route is being added; uses the default<br/>    # virtual network of the account if none is provided. Modifying this attribute will force<br/>    # creation of a new resource.<br/>    virtual_network_id = optional(string)<br/>    # A description of the tunnel route.<br/>    comment = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_tunnel_id"></a> [tunnel\_id](#input\_tunnel\_id) | (Required) The ID of the tunnel that will service the tunnel route. | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_module_enabled"></a> [module\_enabled](#output\_module\_enabled) | Whether the module is enabled or not. |
| <a name="output_routes"></a> [routes](#output\_routes) | The ID of the created tunnel route. |
## Resources

| Name | Type |
|------|------|
| [cloudflare_zero_trust_tunnel_route.route](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zero_trust_tunnel_route) | resource |
<!-- markdownlint-restore -->