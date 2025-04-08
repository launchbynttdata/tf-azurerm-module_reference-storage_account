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
  # source  = "terraform.registry.launch.nttdata.com/module_primitive/monitor_metric_alert/azurerm"
  # version = "~> 1.1"
  source = "git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-monitor_metric_alert.git//.?ref=feature!/expand-variables"

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
  version = "~> 1.0"

  for_each                   = var.diagnostic_settings
  name                       = module.resource_names["diagnostic_setting"].standard
  target_resource_id         = module.storage_account.id
  log_analytics_workspace_id = coalesce(module.log_analytics_workspace[0].id, var.log_analytics_workspace_id)
  enabled_log                = each.value.enabled_log
  metric                     = each.value.metric
  depends_on                 = [module.resource_group]
}
