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

  recovery_services_vault = {
    name       = "rsv"
    max_length = 50
  }

  data_protection_backup_vault = {
    name       = "dpv"
    max_length = 50
  }
}
recovery_services_vault = {
  name                = "example-rsv"
  sku                 = "Standard"
  soft_delete_enabled = true

  identity = {
    type = "SystemAssigned"
  }
}

data_protection_backup_vault = {
  name           = "example-dpv"
  datastore_type = "VaultStore"

  identity = {
    type = "SystemAssigned"
  }
}

blob_backup_policies = {
  blob_policy1 = {
    policy_name = "example-blob-policy"

    backup_repeating_time_intervals = [
      "R/2025-01-01T02:00:00Z/P1D"
    ]

    operational_default_retention_duration = "P30D"
  }
}
file_share_backup_policies = {
  daily = {
    name                  = "daily-policy"
    frequency             = "Daily"
    time                  = "23:00"
    retention_daily_count = 30
  }
}

file_share_backups = {
  share1 = {
    file_share_name = "share1"
    policy_key      = "daily"
  }
}
storage_shares = {
  share1 = {
    name  = "share1"
    quota = 100
  }
}
blob_backup_instances = {
  default = {
    policy_key = "blob_policy1"
  }
}
