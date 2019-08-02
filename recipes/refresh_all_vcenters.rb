#
# Cookbook:: rubrik
# Recipe:: refresh_all_vcenters
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Refreshes the inventory of the all vCenter servers on the Rubrik cluster
#
rubrik_refresh_all_vcenters 'set' do
  action :set
end
