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
recovery_services_vault      = null
data_protection_backup_vault = null
blob_backup_policies         = {}
file_share_backup_policies   = {}
file_share_backups           = {}
storage_shares = {
  share1 = {
    name  = "share1"
    quota = 100
  }
}
blob_backup_instances = {}
