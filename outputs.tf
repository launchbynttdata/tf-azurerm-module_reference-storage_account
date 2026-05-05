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

output "id" {
  description = "The ID of the Storage Account."
  value       = module.storage_account.id
}

output "name" {
  description = "Name of the storage account."
  value       = coalesce(var.storage_account_name, module.resource_names["storage_account"].lower_case_without_any_separators)
}

output "resource_group_name" {
  description = "The name of the resource group in which the storage account is created."
  value       = coalesce(var.resource_group_name, module.resource_names["resource_group"].standard)
}

output "primary_location" {
  description = "The primary location of the storage account."
  value       = module.storage_account.primary_location
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location."
  value       = module.storage_account.primary_blob_endpoint
}

output "primary_web_endpoint" {
  description = "Storage account primary web endpoint."
  value       = module.storage_account.primary_web_endpoint
}

output "primary_connection_string" {
  description = "Primary connection string of the storage account."
  value       = module.storage_account.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "Secondary connection string of the storage account."
  value       = module.storage_account.secondary_connection_string
  sensitive   = true
}

output "primary_access_key" {
  description = "Primary access key of the storage account."
  value       = module.storage_account.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "Secondary access key of the storage account."
  value       = module.storage_account.secondary_access_key
  sensitive   = true
}

output "storage_containers" {
  description = "Storage container resource map."
  value       = module.storage_account.storage_containers
}

output "storage_queues" {
  description = "Storage queues resource map."
  value       = try(module.storage_account.storage_queues, null)
}

output "storage_shares" {
  description = "Storage share resource map."
  value = try({
    for key, share in module.storage_account.storage_shares : key => {
      access_tier          = try(share.access_tier, null)
      acl                  = try(share.acl, [])
      enabled_protocol     = try(share.enabled_protocol, null)
      id                   = share.id
      metadata             = { for mk, mv in try(share.metadata, {}) : mk => mv if lower(mk) != "azurebackupprotected" }
      name                 = share.name
      quota                = share.quota
      resource_manager_id  = try(share.resource_manager_id, null)
      storage_account_name = try(share.storage_account_name, null)
      timeouts             = try(share.timeouts, null)
      url                  = try(share.url, null)
    }
  }, null)
}

output "recovery_services_vault_id" {
  description = "The ID of the Recovery Services Vault."
  value       = try(module.recovery_services_vault[0].vault_id, null)
}

output "data_protection_backup_vault_id" {
  description = "The ID of the Data Protection Backup Vault."
  value       = try(module.data_protection_backup_vault[0].vault_id, null)
}

output "backup_policy_file_share_ids" {
  description = "Map of file share backup policy names to their IDs."
  value = try({
    for key, policy in module.backup_policy_file_share : key => policy.backup_policy_file_share_id
  }, {})
}

output "data_protection_backup_policy_blob_storage_ids" {
  description = "Map of blob storage backup policy names to their IDs."
  value = try({
    for key, policy in module.data_protection_backup_policy_blob_storage : key => policy.id
  }, {})
}

output "backup_protected_file_share_ids" {
  description = "Map of protected file share names to their IDs."
  value = try({
    for key, instance in module.backup_protected_file_share : key => instance.protected_file_share_id
  }, {})
}

output "backup_instance_blob_storage_ids" {
  description = "Map of blob storage backup instance names to their IDs."
  value = try({
    for key, instance in module.backup_instance_blob_storage : key => instance.backup_instance_id
  }, {})
}
