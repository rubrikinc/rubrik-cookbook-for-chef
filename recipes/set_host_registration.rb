#
# Cookbook:: rubrik
# Recipe:: set_host_registration
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Registers current host against the Rubrik cluster
#
rubrik_register_host 'set' do
    action :set
end
