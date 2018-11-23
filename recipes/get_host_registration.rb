#
# Cookbook:: rubrik
# Recipe:: get_host_registration
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Checks if current host is registered against the Rubrik cluster
#
rubrik_register_host 'get' do
  action :get
end
