use_inline_resources

property :sla_domain, String

action :set do
    token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
    if token.nil?
      Chef::Log.error "Something went wrong connecting to the Rubrik cluster"
      exit
    end
    if sla_domain.nil?
        Chef::Log.info ("No SLA domain specified, checking existing configuration for host")
        # get current SLA domain
        sla_domain = Rubrik::ConfMgmt::Core.get_vmware_vm_sla_domain('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ])
        Chef::Log.info ("Current SLA domain is: " + sla_domain)
    end
    Chef::Log.info ("Getting ID for SLA domain: " + sla_domain)
    sla_domain_id = Rubrik::ConfMgmt::Helpers.get_sla_domain_id('https://' + node['rubrik_host'], token, sla_domain)
    
    Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token)
    new_resource.updated_by_last_action(true)
  end
  