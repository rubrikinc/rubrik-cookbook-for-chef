#
# Cookbook:: rubrik
# Recipe:: snapshot_vmware_vm
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Takes an on-demand backup of the current server
#

rubrik_snapshot_vmware_vm 'set' do
    action :set
    sla_domain 'Gold'
end
