# empty
resource_names_map = {
  resource_group = {
    name       = "rg"
    max_length = 80
  }

  storage_account = {
    name       = "sa"
    max_length = 24
  }

  log_analytics_workspace = {
    name       = "law"
    max_length = 80
  }

}
instance_env = 12

recovery_services_vault = {
  sku                           = "Standard"
  public_network_access_enabled = true
  storage_mode_type             = "GeoRedundant"
  cross_region_restore_enabled  = false
  soft_delete_enabled           = false
}

data_protection_backup_vault = {
  datastore_type             = "VaultStore"
  redundancy                 = "LocallyRedundant"
  retention_duration_in_days = 14
  soft_delete                = "Off"
  identity = {
    type = "SystemAssigned"
  }
}

blob_backup_policies = {
  daily_blob_policy = {
    policy_name                      = "daily-blob-policy"
    backup_repeating_time_intervals  = ["R/2024-01-01T02:00:00+00:00/P1D"]
    vault_default_retention_duration = "P30D"
    time_zone                        = "UTC"
    retention_rules                  = []
  }
}

file_share_backup_policies = {
  daily_file_share_policy = {
    name                  = "daily-file-share-policy"
    frequency             = "Daily"
    time                  = "23:00"
    retention_daily_count = 7
  }
}

file_share_backups = {
  share1 = {
    file_share_name = "share1"
    policy_key      = "daily_file_share_policy"
  }
}

storage_containers = {
  storage_container_1 = {
    name                  = "container1"
    container_access_type = "private"
  }
}

blob_versioning_enabled            = true
blob_change_feed_enabled           = true
blob_change_feed_retention_in_days = 7
storage_shares = {
  share1 = {
    name  = "share1"
    quota = 100
    metadata = {
      azurebackupprotected = "false"
    }
  }
}
blob_backup_instances = {
  container1_backup = {
    policy_key                      = "daily_blob_policy"
    storage_account_container_names = ["container1"]
    timeouts = {
      create = "30m"
      read   = "5m"
      update = "30m"
      delete = "30m"
    }
  }
}
