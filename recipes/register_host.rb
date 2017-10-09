#
# Cookbook:: rubrik
# Recipe:: register_host
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Registers the current host against the Rubrik cluster
#
rubrik_register_host 'set' do
  action :set
end