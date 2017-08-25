#
# Cookbook:: rubrik
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

rubrik_cluster_info 'get' do
  action :get
end

rubrik_set_sla 'get' do
  action :get
end

rubrik_set_sla 'set' do
  action :set
end
