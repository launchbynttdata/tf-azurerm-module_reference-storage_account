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

# metric alerts
module "monitor_action_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/monitor_action_group/azurerm"
  version = "~> 1.0.0"

  count               = var.action_group != null ? 1 : 0
  action_group_name   = var.action_group.name
  resource_group_name = coalesce(var.resource_group_name, module.resource_names["resource_group"].standard)
  short_name          = var.action_group.short_name
  arm_role_receivers  = var.action_group.arm_role_receivers
  email_receivers     = var.action_group.email_receivers
  tags                = var.tags
  depends_on          = [module.resource_group]
}

module "monitor_metric_alert" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/monitor_metric_alert/azurerm"
  version = "~> 2.0"

  for_each            = var.metric_alerts
  name                = each.key
  resource_group_name = coalesce(var.resource_group_name, module.resource_names["resource_group"].standard)
  scopes              = [module.storage_account.id]
  description         = each.value.description
  frequency           = each.value.frequency
  severity            = each.value.severity
  enabled             = each.value.enabled
  action_group_ids    = concat([module.monitor_action_group[0].action_group_id], var.action_group_ids)
  webhook_properties  = each.value.webhook_properties
  criteria            = each.value.criteria
  dynamic_criteria    = each.value.dynamic_criteria

  depends_on = [module.resource_group]
}

# diagnostic settings
module "log_analytics_workspace" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/log_analytics_workspace/azurerm"
  version = "~> 1.0"

  count                         = var.log_analytics_workspace != null ? 1 : 0
  name                          = module.resource_names["log_analytics_workspace"].standard
  location                      = var.location
  resource_group_name           = coalesce(var.resource_group_name, module.resource_names["resource_group"].standard)
  sku                           = var.log_analytics_workspace.sku
  retention_in_days             = var.log_analytics_workspace.retention_in_days
  identity                      = var.log_analytics_workspace.identity
  local_authentication_disabled = var.log_analytics_workspace.local_authentication_disabled

  tags       = merge(local.tags, { resource_name = module.resource_names["log_analytics_workspace"].standard })
  depends_on = [module.resource_group]
}

module "diagnostic_setting" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/monitor_diagnostic_setting/azurerm"
  version = "~> 3.0"

  for_each                   = var.diagnostic_settings
  name                       = each.key
  target_resource_id         = module.storage_account.id
  log_analytics_workspace_id = coalesce(module.log_analytics_workspace[0].id, var.log_analytics_workspace_id)
  enabled_log                = each.value.enabled_log
  metrics                    = each.value.metrics
  depends_on                 = [module.resource_group]
}
module "recovery_services_vault" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/recovery_services_vault/azurerm"
  version = "~> 1.0"

  count = var.recovery_services_vault != null ? 1 : 0

  name                = try(var.recovery_services_vault.name, module.resource_names["recovery_services_vault"].standard, null)
  location            = var.location
  resource_group_name = coalesce(var.resource_group_name, module.resource_names["resource_group"].standard)
  sku                 = var.recovery_services_vault.sku

  public_network_access_enabled      = var.recovery_services_vault.public_network_access_enabled
  immutability                       = var.recovery_services_vault.immutability
  storage_mode_type                  = var.recovery_services_vault.storage_mode_type
  cross_region_restore_enabled       = var.recovery_services_vault.cross_region_restore_enabled
  soft_delete_enabled                = var.recovery_services_vault.soft_delete_enabled
  classic_vmware_replication_enabled = var.recovery_services_vault.classic_vmware_replication_enabled

  identity   = var.recovery_services_vault.identity
  encryption = var.recovery_services_vault.encryption
  monitoring = var.recovery_services_vault.monitoring

  tags = merge(local.tags, var.tags)

  depends_on = [
    module.resource_group,
    module.storage_account
  ]
}
resource "azurerm_backup_container_storage_account" "registration" {
  resource_group_name = coalesce(var.resource_group_name, module.resource_names["resource_group"].standard)

  recovery_vault_name = module.recovery_services_vault[0].vault_name

  storage_account_id = module.storage_account.id

  depends_on = [
    module.recovery_services_vault,
    module.storage_account
  ]
}

module "data_protection_backup_vault" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/data_protection_backup_vault/azurerm"
  version = "~> 0.1.1"

  count               = var.data_protection_backup_vault != null ? 1 : 0
  name                = try(var.data_protection_backup_vault.name, module.resource_names["data_protection_backup_vault"].standard, null)
  location            = var.location
  resource_group_name = coalesce(var.resource_group_name, module.resource_names["resource_group"].standard)

  datastore_type = var.data_protection_backup_vault.datastore_type
  redundancy     = var.data_protection_backup_vault.redundancy

  soft_delete                = var.data_protection_backup_vault.soft_delete
  retention_duration_in_days = var.data_protection_backup_vault.retention_duration_in_days

  identity = var.data_protection_backup_vault.identity

  tags = merge(local.tags, var.tags)

  depends_on = [
    module.resource_group,
    module.storage_account
  ]
}
module "data_protection_backup_policy_blob_storage" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/data_protection_backup_policy_blob_storage/azurerm"
  version = "~> 1.0"

  for_each = var.blob_backup_policies != null ? var.blob_backup_policies : {}

  policy_name = each.value.policy_name
  vault_id    = module.data_protection_backup_vault[0].vault_id

  backup_repeating_time_intervals        = each.value.backup_repeating_time_intervals
  operational_default_retention_duration = each.value.operational_default_retention_duration
  vault_default_retention_duration       = each.value.vault_default_retention_duration
  time_zone                              = each.value.time_zone

  retention_rules = each.value.retention_rules
  timeouts        = each.value.timeouts

  depends_on = [
    module.data_protection_backup_vault
  ]
}

resource "azurerm_backup_policy_file_share" "file_share_policy" {
  for_each = var.file_share_backup_policies

  name                = each.value.name
  resource_group_name = coalesce(var.resource_group_name, module.resource_names["resource_group"].standard)
  recovery_vault_name = module.recovery_services_vault[0].vault_name

  backup {
    frequency = each.value.frequency
    time      = each.value.time
  }

  retention_daily {
    count = each.value.retention_daily_count
  }
}
module "backup_protected_file_share" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/backup_protected_file_share/azurerm"
  version = "~> 0.2"

  for_each = var.file_share_backups != null ? var.file_share_backups : {}

  resource_group_name       = coalesce(var.resource_group_name, module.resource_names["resource_group"].standard)
  recovery_vault_name       = module.recovery_services_vault[0].vault_name
  source_storage_account_id = module.storage_account.id
  file_share_name           = each.value.file_share_name

  backup_policy_id = azurerm_backup_policy_file_share.file_share_policy[each.value.policy_key].id

  depends_on = [
    azurerm_backup_container_storage_account.registration,
    module.storage_account
  ]
}

resource "azurerm_data_protection_backup_instance_blob_storage" "blob_backup" {
  for_each = var.blob_backup_instances

  name               = each.key
  vault_id           = module.data_protection_backup_vault[0].vault_id
  location           = var.location
  storage_account_id = module.storage_account.id

  backup_policy_id = module.data_protection_backup_policy_blob_storage[each.value.policy_key].id
}
