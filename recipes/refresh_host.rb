#
# Cookbook:: rubrik
# Recipe:: refresh_host
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Refreshes the inventory of the current host on the Rubrik cluster
#
rubrik_refresh_host 'set' do
    action :set
end
