#
# Cookbook:: rubrik
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

rubrik_cluster_info 'get' do
  action :list
end
