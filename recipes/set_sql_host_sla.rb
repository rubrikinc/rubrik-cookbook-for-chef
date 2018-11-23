#
# Cookbook:: rubrik
# Recipe:: set_sql_host_sla
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Sets SLA for the SQL instances on this host
#
rubrik_sql_host_sla 'set' do
  action :set
end
