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

  region                  = var.location
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  maximum_length          = each.value.max_length
  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.1"

  name     = local.resource_group_name
  location = var.location
  tags     = { resource_group_name = local.resource_group_name }
}

module "storage_account" {
  source = "../.."

  resource_group_name  = local.resource_group_name
  location             = var.location
  storage_account_name = coalesce(var.storage_account_name, local.storage_account_name)
  storage_containers = merge(var.storage_containers, {
    storage_container_1 = {
      name                  = "container1"
      container_access_type = "private"
    }
  })

  # account_tier              = var.account_tier
  # account_replication_type  = var.account_replication_type
  # storage_containers        = var.storage_containers
  # storage_shares            = var.storage_shares
  # storage_queues            = var.storage_queues
  # static_website            = var.static_website
  # enable_https_traffic_only = var.enable_https_traffic_only
  # access_tier               = var.access_tier
  # account_kind              = var.account_kind

  # blob_cors_rule                         = var.blob_cors_rule
  # blob_delete_retention_policy           = var.blob_delete_retention_policy
  # blob_versioning_enabled                = var.blob_versioning_enabled
  # blob_change_feed_enabled               = var.blob_change_feed_enabled
  # blob_last_access_time_enabled          = var.blob_last_access_time_enabled
  # blob_container_delete_retention_policy = var.blob_container_delete_retention_policy
  # public_network_access_enabled          = var.public_network_access_enabled
  # network_rules                          = var.network_rules

  action_group = coalesce({
    name       = "example-action-group"
    short_name = "exag"
    arm_role_receivers = [
      {
        name                    = "example-arm-role"
        role_id                 = "b24988ac-6180-42a0-ab88-20f7382dd24c"
        use_common_alert_schema = true
      }
    ]
    email_receivers = [
      {
        name                    = "example-email"
        email_address           = "example@test.com"
        use_common_alert_schema = true
      }
  ] }, var.action_group)

  metric_alerts = merge(var.metric_alerts, {
    storage_availability = {
      description = "Alert when storage availability drops"
      frequency   = "PT5M" # 5 minutes
      severity    = 2
      enabled     = true
      criteria = [{
        metric_namespace = "Microsoft.Storage/storageAccounts"
        metric_name      = "Availability"
        aggregation      = "Average"
        operator         = "LessThan"
        threshold        = 99.9
        dimensions = [{
          name     = "AccountName"
          operator = "Include"
          values   = ["*"]
        }]
      }]
    },
    storage_used_capacity = {
      description = "Alert on storage capacity changes"
      frequency   = "PT15M" # 15 minutes
      severity    = 3
      enabled     = true
      criteria    = []
      dynamic_criteria = {
        metric_namespace  = "Microsoft.Storage/storageAccounts"
        metric_name       = "UsedCapacity"
        aggregation       = "Average"
        operator          = "GreaterThan"
        alert_sensitivity = "Medium"
        dimensions = [{
          name     = "AccountName"
          operator = "Include"
          values   = ["*"]
        }]
      }
    },
    storage_transactions = {
      description = "Alert on high number of failed transactions"
      frequency   = "PT5M"
      severity    = 2
      enabled     = true
      criteria = [{
        metric_namespace = "Microsoft.Storage/storageAccounts"
        metric_name      = "Transactions"
        aggregation      = "Total"
        operator         = "GreaterThan"
        threshold        = 1000
        dimensions = [{
          name     = "ResponseType"
          operator = "Include"
          values   = ["Error"]
        }]
      }]
    }
  })

  log_analytics_workspace = try({
    sku                           = "PerGB2018"
    retention_in_days             = 30
    daily_quota_gb                = 10
    identity                      = null
    local_authentication_disabled = false
  }, var.log_analytics_workspace)

  diagnostic_settings = merge(var.diagnostic_settings, {
    transactions = {
      enabled_log = [
        {
          category_group = "allLogs"
          category       = "StorageRead"
        },
        {
          category_group = "allLogs"
          category       = "StorageWrite"
        },
        {
          category_group = "allLogs"
          category       = "StorageDelete"
        }
      ]
      metric = {
        category = "Transaction"
        enabled  = true
      }
    }
    capacity = {
      enabled_log = [
        {
          category_group = "allLogs"
          category       = "StorageRead"
        },
        {
          category_group = "allLogs"
          category       = "StorageWrite"
        },
        {
          category_group = "allLogs"
          category       = "StorageDelete"
        }
      ]
      metric = {
        category = "Capacity"
        enabled  = true
      }
    }
  })

  depends_on = [module.resource_group]
}
