// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.location
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  maximum_length          = each.value.max_length
  instance_resource       = var.instance_resource
  use_azure_region_abbr   = var.use_azure_region_abbr
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.1"

  count    = var.resource_group_name == null ? 1 : 0
  name     = module.resource_names["resource_group"].standard
  location = var.location

  tags = merge(local.tags, var.tags, { resource_name = module.resource_names["resource_group"].standard })
}

module "storage_account" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/storage_account/azurerm"
  version = "~> 1.0"

  resource_group_name  = coalesce(var.resource_group_name, module.resource_names["resource_group"].standard)
  location             = var.location
  storage_account_name = coalesce(var.storage_account_name, module.resource_names["storage_account"].lower_case_without_any_separators)

  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type
  storage_containers        = var.storage_containers
  storage_shares            = var.storage_shares
  storage_queues            = var.storage_queues
  static_website            = var.static_website
  enable_https_traffic_only = var.enable_https_traffic_only
  access_tier               = var.access_tier
  account_kind              = var.account_kind

  blob_cors_rule                         = var.blob_cors_rule
  blob_delete_retention_policy           = var.blob_delete_retention_policy
  blob_versioning_enabled                = var.blob_versioning_enabled
  blob_change_feed_enabled               = var.blob_change_feed_enabled
  blob_last_access_time_enabled          = var.blob_last_access_time_enabled
  blob_container_delete_retention_policy = var.blob_container_delete_retention_policy
  public_network_access_enabled          = var.public_network_access_enabled
  network_rules                          = var.network_rules

  tags = merge(local.tags, var.tags, { resource_name = coalesce(var.storage_account_name, module.resource_names["storage_account"].standard) })
}

# module "storage_containers" {
#   source  = "terraform.registry.launch.nttdata.com/module_primitive/storage_container/azurerm"
#   version = "~> 1.0"

#   for_each                          = var.storage_containers
#   name                              = each.key
#   storage_account_name              = module.storage_account.name
#   container_access_type             = each.value.container_access_type
#   default_encryption_scope          = each.value.default_encryption_scope
#   encryption_scope_override_enabled = each.value.encryption_scope_override_enabled
#   metadata                          = each.value.metadata
# }
