#
# Cookbook:: rubrik
# Recipe:: od_backup
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Takes an on-demand backup of the current server
#

rubrik_od_backup 'set' do
    action :set
    sla_domain 'Gold'
end