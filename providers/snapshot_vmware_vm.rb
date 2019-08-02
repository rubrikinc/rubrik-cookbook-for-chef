use_inline_resources

action :set do
  if node['rubrik_http_timeout']
    timeout = node['rubrik_http_timeout']
  else
    timeout = 60 # this is the default in the Ruby HTTP library
  end
  token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'], timeout)
  if token.nil?
    Chef::Log.error 'Something went wrong connecting to the Rubrik cluster'
    exit
  end
  # If we have not specified the SLA domain, then get the current protection for the host
  if new_resource.sla_domain.nil?
    Chef::Log.info 'No SLA domain specified, checking existing configuration for host'
    # get current SLA domain
    sla_domain = Rubrik::ConfMgmt::Core.get_vmware_vm_sla_domain('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ], timeout)
    Chef::Log.info 'Current SLA domain is: ' + sla_domain
  else
    sla_domain = new_resource.sla_domain
  end
  # Get the ID for our SLA domain (or return nil, if snapshot is to be unprotected)
  if sla_domain != 'Unprotected'
    Chef::Log.info 'Getting ID for SLA domain: ' + sla_domain
    sla_domain_id = Rubrik::ConfMgmt::Helpers.get_sla_domain_id('https://' + node['rubrik_host'], token, sla_domain, timeout)
  else
    Chef::Log.info 'No SLA Domain found, or specified, will take snapshot with no retention policy (unmanaged)'
    sla_domain_id = nil
  end
  # Get our VM ID
  vm_id = Rubrik::ConfMgmt::Helpers.get_vmware_vm_id('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ], timeout)
  # Take on-demand snapshot
  Chef::Log.info 'Triggering snapshot...'
  Rubrik::ConfMgmt::Core.take_od_snapshot('https://' + node['rubrik_host'], token, vm_id, sla_domain_id, timeout)
  Chef::Log.info 'Snapshot initialisation complete'
  Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token, timeout)
  new_resource.updated_by_last_action(true)
end