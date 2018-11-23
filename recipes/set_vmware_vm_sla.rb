#
# Cookbook:: rubrik
# Recipe:: set_vmware_vm_sla
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Configures the SLA for the host
#
rubrik_vmware_vm_sla 'set' do
  action :set
  crash_consistent false
end
