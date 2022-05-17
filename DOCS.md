## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_automation_account.aa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automation_account_name"></a> [automation\_account\_name](#input\_automation\_account\_name) | The name of the automation account | `string` | n/a | yes |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of user managed identity ids to be assigned to the VM. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The Managed Service Identity Type of this Virtual Machine. | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | If public network access is enabled | `bool` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU of the automation account, Basic is the only supported value | `string` | `"Basic"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | <pre>{<br>  "source": "terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aa_dsc_primary_access_key"></a> [aa\_dsc\_primary\_access\_key](#output\_aa\_dsc\_primary\_access\_key) | The DSC primary access key |
| <a name="output_aa_dsc_secondary_access_key"></a> [aa\_dsc\_secondary\_access\_key](#output\_aa\_dsc\_secondary\_access\_key) | The DSC secondary access key |
| <a name="output_aa_dsc_server_endpoint"></a> [aa\_dsc\_server\_endpoint](#output\_aa\_dsc\_server\_endpoint) | The DSC server endpoint of the automation account |
| <a name="output_aa_id"></a> [aa\_id](#output\_aa\_id) | The ID of the automation account |
| <a name="output_aa_identity"></a> [aa\_identity](#output\_aa\_identity) | The identity block of the automation account |
| <a name="output_aa_name"></a> [aa\_name](#output\_aa\_name) | The name of the automation account |
