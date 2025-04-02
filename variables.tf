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

# Common Properties
variable "resource_group_name" {
  description = "target resource group resource mask"
  type        = string
}

variable "location" {
  type        = string
  description = "(Required) Specifies the supported Azure location where the resource exists."
}

variable "resource_names_map" {
  description = "A map of keys to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object({
    name       = string
    max_length = optional(number, 60)
  }))

  default = {
    resource_group = {
      name       = "rg"
      max_length = 80
    }
    storage_account = {
      name       = "sa"
      max_length = 24
    }
    storage_container = {
      name       = "sc"
      max_length = 63
    }
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# module resource_names properties
variable "instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  default     = 0

  validation {
    condition     = var.instance_env >= 0 && var.instance_env <= 999
    error_message = "Instance number should be between 0 to 999."
  }
}

variable "instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  default     = 0

  validation {
    condition     = var.instance_resource >= 0 && var.instance_resource <= 100
    error_message = "Instance number should be between 0 to 100."
  }
}

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "launch"
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "sta"
}

variable "class_env" {
  type        = string
  description = "(Required) Environment where resource is going to be deployed. For example. dev, qa, uat"
  nullable    = false
  default     = "dev"

  validation {
    condition     = length(regexall("\\b \\b", var.class_env)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

variable "use_azure_region_abbr" {
  type        = bool
  description = "Use Azure region abbreviation in resource names."
  default     = true
}

# storage account properties
variable "storage_account_name" {
  description = "The name of the storage account."
  type        = string
  default     = null
}

variable "account_tier" {
  description = "value of the account_tier"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "value of the account_replication_type"
  type        = string
  default     = "LRS"
}

variable "storage_containers" {
  description = "map of storage container configs, keyed polymorphically"
  type = map(object({
    name                  = string
    container_access_type = string
  }))
  default = {}
}

variable "storage_shares" {
  description = "map of storage file shares configs, keyed polymorphically"
  type = map(object({
    name  = string
    quota = number
  }))
  default = {}
}

variable "storage_queues" {
  description = "map of storage queue configs, keyed polymorphically"
  type = map(object({
    name = string
  }))
  default = {}
}

variable "static_website" {
  description = "The static website details if the storage account needs to be used as a static website"
  type = object({
    index_document     = string
    error_404_document = string
  })
  default = null
}

variable "enable_https_traffic_only" {
  description = "Boolean flag that forces HTTPS traffic only"
  type        = bool
  default     = true
}

variable "access_tier" {
  description = "Choose between Hot or Cool"
  type        = string
  default     = "Hot"

  validation {
    condition     = (contains(["hot", "cool"], lower(var.access_tier)))
    error_message = "The account_tier must be either \"Hot\" or \"Cool\"."
  }

}

variable "account_kind" {
  description = "Defines the kind of account"
  type        = string
  default     = "StorageV2"
}

# storage account: blob related properties
variable "blob_cors_rule" {
  description = "Blob cors rules"
  type = map(object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))

  default = null
}

variable "blob_delete_retention_policy" {
  description = "Number of days the blob should be retained. Set 0 to disable"
  type        = number
  default     = 0
}

variable "blob_versioning_enabled" {
  description = "Is blob versioning enabled for blob"
  type        = bool
  default     = false
}

variable "blob_change_feed_enabled" {
  description = "Is the blobl service properties for change feed enabled for blob"
  type        = bool
  default     = false
}

variable "blob_last_access_time_enabled" {
  description = "Is the last access time based tracking enabled"
  type        = bool
  default     = false
}

variable "blob_container_delete_retention_policy" {
  description = "Specify the number of days that the container should be retained. Set 0 to disable"
  type        = number
  default     = 0
}

variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled. Defaults to `true`."
  type        = bool
  default     = true
}

variable "network_rules" {
  description = "An object defining rules around network access for the Storage Account."
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(list(string), ["AzureServices", "Logging", "Metrics"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
    private_link_access = optional(list(object({
      endpoint_resource_id = string
      endpoint_tenant_id   = optional(string, null)
    })), [])
  })
  default = null
}

# # storage container properties
# variable "storage_containers" {
#   description = "A map of storage container configurations."
#   type = map(object({
#     name                  = string
#     container_access_type = optional(string, null)
#     default_encryption_scope = optional(string, null)
#     encryption_scope_override_enabled = optional(bool, null)
#     metadata              = optional(map(string), null)
#   }))
#   default = {}
# }

# variable "container_access_type" {
#   description = "The access type of the storage container."
#   type        = string
#   default     = null
# }

# variable "default_encryption_scope" {
#   description = "The default encryption scope for the storage container."
#   type        = string
#   default     = null
# }

# variable "encryption_scope_override_enabled" {
#   description = "Specifies if encryption scope override is enabled."
#   type        = bool
#   default     = null
# }

# variable "metadata" {
#   description = "A mapping of metadata to assign to the storage container."
#   type        = map(string)
#   default     = null
# }
