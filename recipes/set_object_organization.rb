#
# Cookbook:: rubrik
# Recipe:: set_object_organization
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Adds the current host to the organization name set in node['rubrik_org_name']
#
rubrik_object_organization 'set' do
  action :set
  object_type 'host'
end
