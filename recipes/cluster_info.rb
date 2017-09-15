#
# Cookbook:: rubrik
# Recipe:: cluster_info
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Displays information about the cluster in the chef-client log
#
rubrik_cluster_info 'get' do
  action :get
end
