#
# Cookbook:: rubrik
# Recipe:: create_fileset
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Creates filesets for the host based on host attributes
#
rubrik_fileset 'set' do
    action :set
end
