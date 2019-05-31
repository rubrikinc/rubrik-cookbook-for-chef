#
# Cookbook:: rubrik
# Recipe:: get_object_organization
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Checks the current host is managable by the organization name set in node['rubrik_org_name']
#
rubrik_object_organization 'get' do
  action :get
  object_type 'host'
end
