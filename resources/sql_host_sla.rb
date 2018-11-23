actions :get, :set
default_action :get

property :log_backup_freq_minutes, Integer, default: 30
property :log_retention_days, Integer, default: 7
