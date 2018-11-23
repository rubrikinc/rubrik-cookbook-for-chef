#
# Cookbook:: rubrik
# Recipe:: get_filesets
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Pulls out information on the current filesets for the host
#
rubrik_fileset 'get' do
    action :get
end
