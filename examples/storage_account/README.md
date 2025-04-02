# storage_account

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.117 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm | ~> 1.1 |
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | (Required) Specifies the supported Azure location where the resource exists. | `string` | `"eastus"` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of keys to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object({<br/>    name       = string<br/>    max_length = optional(number, 60)<br/>  }))</pre> | <pre>{<br/>  "resource_group": {<br/>    "max_length": 80,<br/>    "name": "rg"<br/>  },<br/>  "storage_account": {<br/>    "max_length": 24,<br/>    "name": "sa"<br/>  },<br/>  "storage_container": {<br/>    "max_length": 63,<br/>    "name": "sc"<br/>  }<br/>}</pre> | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Number that represents the instance of the environment. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Number that represents the instance of the resource. | `number` | `0` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br/>    Example: org\_name, department\_name. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br/>    For example, backend, frontend, middleware etc. | `string` | `"sta"` | no |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | (Required) Environment where resource is going to be deployed. For example. dev, qa, uat | `string` | `"dev"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the storage account. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the storage account. |
| <a name="output_name"></a> [name](#output\_name) | Name of the storage account. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group in which the storage account is created. |
| <a name="output_primary_location"></a> [primary\_location](#output\_primary\_location) | The primary location of the storage account. |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The endpoint URL for blob storage in the primary location. |
| <a name="output_primary_web_endpoint"></a> [primary\_web\_endpoint](#output\_primary\_web\_endpoint) | Storage account primary web endpoint. |
| <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string) | Primary connection string of the storage account. |
| <a name="output_secondary_connection_string"></a> [secondary\_connection\_string](#output\_secondary\_connection\_string) | Secondary connection string of the storage account. |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | Primary access key of the storage account. |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | Secondary access key of the storage account. |
| <a name="output_storage_containers"></a> [storage\_containers](#output\_storage\_containers) | Storage container resource map. |
| <a name="output_storage_queues"></a> [storage\_queues](#output\_storage\_queues) | Storage queues resource map. |
| <a name="output_storage_shares"></a> [storage\_shares](#output\_storage\_shares) | Storage share resource map. |
<!-- END_TF_DOCS -->
