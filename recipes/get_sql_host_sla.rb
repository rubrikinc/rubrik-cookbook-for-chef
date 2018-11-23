#
# Cookbook:: rubrik
# Recipe:: get_sql_host_sla
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Pulls out information on the current SLA for the SQL instances on this host
#
rubrik_sql_host_sla 'get' do
  action :get
end
