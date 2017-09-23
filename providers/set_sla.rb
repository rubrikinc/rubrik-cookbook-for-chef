use_inline_resources

action :get do
  token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
  if token.nil?
    Chef::Log.error "Something went wrong connecting to the Rubrik cluster"
    exit
  end
  # get current SLA domain
  current_domain = Rubrik::ConfMgmt::Core.get_vmware_vm_sla_domain('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ])
  Chef::Log.info ("Current SLA domain is: " + current_domain)
  Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token)
  new_resource.updated_by_last_action(true)
end

action :set do
  token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
  if token.nil?
    Chef::Log.error "Something went wrong connecting to the Rubrik cluster"
    exit
  end
  current_domain = Rubrik::ConfMgmt::Core.get_vmware_vm_sla_domain('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ])
  if current_domain != node['rubrik_sla_domain']
    domain_update = Rubrik::ConfMgmt::Core.set_vmware_vm_sla_domain('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ], node['rubrik_sla_domain'])
    if domain_update.nil?
      Chef::Log.error "Something went wrong updating the SLA domain"
      exit
    end
    Chef::Log.info ("Updated SLA domain to: " + node['rubrik_sla_domain'])
  else
    Chef::Log.info ("SLA domain already set to: " + node['rubrik_sla_domain'] + ", nothing to do...")
  end
  Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token)
  new_resource.updated_by_last_action(true)
end
