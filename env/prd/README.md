<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.0 |
| <a name="requirement_curl"></a> [curl](#requirement\_curl) | 1.0.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.105.0 |
| <a name="provider_curl"></a> [curl](#provider\_curl) | 1.0.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.2 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vm_linux"></a> [vm\_linux](#module\_vm\_linux) | ../../modules/VMs | n/a |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ../../modules/network/vnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_disk_encryption_set.disk_encryption_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/disk_encryption_set) | resource |
| [azurerm_key_vault.KeyVault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.current_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.des](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_key.des_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_key.storage_account_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_network_interface_security_group_association.linux_nic_assoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.vm_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_role_assignment.disk-encryption-read-keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.storage_account_key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_id.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.pip](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_string.key_vault_prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/3.0.0/docs/resources/private_key) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_public_ip.pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip) | data source |
| [curl_curl.my_ip](https://registry.terraform.io/providers/anschoewe/curl/1.0.2/docs/data-sources/curl) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | n/a | `string` | `"azureuser"` | no |
| <a name="input_create_disk_encryption_resources"></a> [create\_disk\_encryption\_resources](#input\_create\_disk\_encryption\_resources) | Flag to determine whether to create disk encryption resources | `bool` | `false` | no |
| <a name="input_create_network_watcher"></a> [create\_network\_watcher](#input\_create\_network\_watcher) | n/a | `bool` | `false` | no |
| <a name="input_create_public_ip"></a> [create\_public\_ip](#input\_create\_public\_ip) | n/a | `bool` | `false` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | n/a | `bool` | `true` | no |
| <a name="input_env"></a> [env](#input\_env) | n/a | `string` | `"prd"` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `any` | n/a | yes |
| <a name="input_managed_identity_principal_id"></a> [managed\_identity\_principal\_id](#input\_managed\_identity\_principal\_id) | n/a | `string` | `null` | no |
| <a name="input_my_public_ip"></a> [my\_public\_ip](#input\_my\_public\_ip) | n/a | `string` | `null` | no |
| <a name="input_pip_count"></a> [pip\_count](#input\_pip\_count) | n/a | `any` | n/a | yes |
| <a name="input_purpose"></a> [purpose](#input\_purpose) | n/a | `string` | `"demo"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | `"pyo-rg"` | no |
| <a name="input_size"></a> [size](#input\_size) | n/a | `string` | `"Standard_F2"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnet configurations | <pre>map(object({<br>    subnet_name           = string<br>    subnet_address_prefix = list(string)<br>    # service_endpoints                   = list(string)<br>    # service_endpoint_policy_ids         = list(string)<br>    # private_endpoint_network_policies_enabled     = bool<br>    # private_link_service_network_policies_enabled = bool<br>    delegation = optional(object({<br>      name = string<br>      service_delegation = object({<br>        name    = string<br>        actions = list(string)<br>      })<br>    }))<br>    nsg_inbound_rules  = optional(list(list(string)), [])<br>    nsg_outbound_rules = optional(list(list(string)), [])<br>  }))</pre> | `{}` | no |
| <a name="input_vms"></a> [vms](#input\_vms) | List of VMs to create | <pre>list(object({<br>    vm_name = string<br>    os_disk = object({<br>      caching = string<br>      storage_account_type = string<br>    })<br>    admin_username = optional(string, "azureuser")<br>    size = string<br>    subnet = string<br>    custom_data = optional(string)<br>    os_simple = optional(string)<br>    source_image_id = optional(string)<br>    source_image_reference = optional(map(string))<br>  }))</pre> | n/a | yes |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | n/a | `list` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | n/a | `string` | `"pyo-vnet"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_linux_public_ip"></a> [linux\_public\_ip](#output\_linux\_public\_ip) | n/a |
| <a name="output_public_ip_address_ids"></a> [public\_ip\_address\_ids](#output\_public\_ip\_address\_ids) | n/a |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The id of the resource group in which resources are created |
| <a name="output_resource_group_location"></a> [resource\_group\_location](#output\_resource\_group\_location) | The location of the resource group in which resources are created |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group in which resources are created |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | The IDs of the subnets |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | The ID of the virtual network |
<!-- END_TF_DOCS -->