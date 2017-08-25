use_inline_resources

action :get do
  token = Rubrik::Api::Session.post_session(node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
  # get current SLA domain
  current_domain = Rubrik::ConfMgmt::Core.get_vm_sla_domain(node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ])
  puts "\r\nCurrent SLA domain is: " + current_domain
  new_resource.updated_by_last_action(true)
end

action :set do
  token = Rubrik::Api::Session.post_session(node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
  domain_update = Rubrik::ConfMgmt::Core.set_vm_sla_domain(node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ], node['rubrik_sla_domain'])
  puts "\r\nUpdated SLA domain to: " + node['rubrik_sla_domain']
  new_resource.updated_by_last_action(true)
end
