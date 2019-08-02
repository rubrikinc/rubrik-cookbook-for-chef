use_inline_resources

action :get do
  if node['rubrik_http_timeout']
    timeout = node['rubrik_http_timeout']
  else
    timeout = 60 # this is the default in the Ruby HTTP library
  end
  token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'], timeout)
  if token.nil?
    Chef::Log.error "Something went wrong connecting to the Rubrik cluster"
    exit
  end
  # get current SLA domain
  current_domain = Rubrik::ConfMgmt::Core.get_vmware_vm_sla_domain('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ], timeout)
  Chef::Log.info ("Current SLA domain is: " + current_domain)
  # get crash consistency settings
  consistency = Rubrik::ConfMgmt::Core.get_vmware_vm_consistency('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ], timeout)
  if ['APP_CONSISTENT','UNKNOWN'].include? consistency
    Chef::Log.info ("Current consistency level is: APP_CONSISTENT")
  elsif ['CRASH_CONSISTENT'].include? consistency
    Chef::Log.info ("Current consistency level is: "+consistency)
  else
    Chef::Log.info ("Current consistency level is: "+consistency)
  end
  Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token, timeout)
  new_resource.updated_by_last_action(true)
end

action :set do
  if node['rubrik_http_timeout']
    timeout = node['rubrik_http_timeout']
  else
    timeout = 60 # this is the default in the Ruby HTTP library
  end
  token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'], timeout)
  if token.nil?
    Chef::Log.error "Something went wrong connecting to the Rubrik cluster"
    exit
  end
  current_domain = Rubrik::ConfMgmt::Core.get_vmware_vm_sla_domain('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ], timeout)
  if current_domain != node['rubrik_sla_domain']
    domain_update = Rubrik::ConfMgmt::Core.set_vmware_vm_sla_domain('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ], node['rubrik_sla_domain'], timeout)
    if domain_update.nil?
      Chef::Log.error "Something went wrong updating the SLA domain"
      exit
    end
    Chef::Log.info ("Updated SLA domain to: " + node['rubrik_sla_domain'])
  else
    Chef::Log.info ("SLA domain already set to: " + node['rubrik_sla_domain'] + ", nothing to do...")
  end
  # set crash consistency settings
  current_consistency = Rubrik::ConfMgmt::Core.get_vmware_vm_consistency('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ], timeout)
  if new_resource.crash_consistent == true
    if current_consistency == 'CRASH_CONSISTENT'
      Chef::Log.info ("VM is already crash consistent, nothing to do...")
    else
      consistency_update = Rubrik::ConfMgmt::Core.set_vmware_vm_consistency('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ], 'CRASH_CONSISTENT', timeout)
      if consistency_update.nil?
        Chef::Log.error "Something went wrong updating the consistency"
        exit
      end
      Chef::Log.info ("Updated VM to be crash consistent")
    end
  else
    if current_consistency == 'CRASH_CONSISTENT'
      consistency_update = Rubrik::ConfMgmt::Core.set_vmware_vm_consistency('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ], '', timeout)
      if consistency_update.nil?
        Chef::Log.error "Something went wrong updating the consistency"
        exit
      end
      Chef::Log.info ("Updated VM to be application consistent")
    else
      Chef::Log.info ("VM is already application consistent, nothing to do...")
    end
  end
  Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token, timeout)
  new_resource.updated_by_last_action(true)
end

