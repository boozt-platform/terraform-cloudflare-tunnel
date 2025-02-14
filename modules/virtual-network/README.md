# terraform-cloudflare-tunnel/virtual-network

The virtual-network module in the terraform-cloudflare-tunnel repository
is designed to create and manage Cloudflare Virtual Networks within a Zero
Trust architecture. This module facilitates the segmentation of your network
by establishing isolated virtual networks, allowing for organized and secure
routing of traffic through Cloudflare Tunnels.

```hcl
module "virtual_network" {
  source     = "github.com/boozt-platform/terraform-cloudflare-tunnel//modules/virtual-network"
  api_token  = var.api_token
  account_id = var.account_id

  virtual_network_name    = "example-network"
  virtual_network_comment = "This is an example virtual network"
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
| <a name="input_virtual_network_comment"></a> [virtual\_network\_comment](#input\_virtual\_network\_comment) | (Optional) Description of the tunnel virtual network. | `string` | `null` | no |
| <a name="input_virtual_network_is_default_network"></a> [virtual\_network\_is\_default\_network](#input\_virtual\_network\_is\_default\_network) | (Optional) Whether this virtual network is the default one for the account. | `bool` | `false` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | (Required) A user-friendly name chosen when the virtual network is created. | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_module_enabled"></a> [module\_enabled](#output\_module\_enabled) | Whether the module is enabled or not. |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | The ID of the created virtual network. |
| <a name="output_virtual_network_name"></a> [virtual\_network\_name](#output\_virtual\_network\_name) | The name of the created virtual network. |
## Resources

| Name | Type |
|------|------|
| [cloudflare_zero_trust_tunnel_virtual_network.virtual_network](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zero_trust_tunnel_virtual_network) | resource |
<!-- markdownlint-restore -->