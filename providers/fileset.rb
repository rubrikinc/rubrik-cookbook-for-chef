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
  host_id = Rubrik::ConfMgmt::Core.get_registered_host_id('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ], timeout)
  if host_id.nil?
    Chef::Log.info ("Host is not registered against the Rubrik cluster")
  else
    Chef::Log.info ("Host Current host ID is: " + host_id)
    host_filesets = Rubrik::Api::Fileset.get_filesets_for_host('https://' + node['rubrik_host'], token, host_id, timeout)
    Chef::Log.info ("This host has " + host_filesets.count.to_s + " filesets currently assigned")
    if host_filesets.count > 0
      for host_fileset in host_filesets
        Chef::Log.info ("Fileset '" + host_fileset['name'] + "' found, with ID: " + host_fileset['id'] + ", and SLA domain: " + host_fileset['configuredSlaDomainName'])
      end
    end
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
  # get current SLA domain
  host_id = Rubrik::ConfMgmt::Core.get_registered_host_id('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ], timeout)
  if host_id.nil?
    Chef::Log.info ('Host is not registered against the Rubrik cluster')
    break
  else
    Chef::Log.info ('Host Current host ID is: ' + host_id)
    host_filesets = Rubrik::Api::Fileset.get_filesets_for_host('https://' + node['rubrik_host'], token, host_id, timeout)
    for fileset in node['rubrik_fileset']
      existing_fileset = Rubrik::Api::Fileset.get_fileset_by_name_for_host('https://' + node['rubrik_host'], token, host_id, fileset, timeout)
      if existing_fileset.count == 0
        Chef::Log.info ("Fileset " + fileset + " does not presently exist for this host, creating...")
        fileset_template = Rubrik::Api::FilesetTemplate.get_fileset_template_by_name('https://' + node['rubrik_host'], token, fileset, timeout)
        if fileset_template == false
          Chef::Log.error "Unable to find fileset template named " + fileset
        else
          create_fileset = Rubrik::Api::Fileset.create_fileset('https://' + node['rubrik_host'], token, host_id, fileset_template['id'], timeout)
          if create_fileset == false
            Chef::Log.error "Something went wrong creating the fileset"
          else
            fileset_id = create_fileset['id']
            sla_domain_id = Rubrik::ConfMgmt::Helpers.get_sla_domain_id('https://' + node['rubrik_host'], token, node['rubrik_sla_domain'], timeout)
            if sla_domain_id.nil?
              Chef::Log.error "Something went wrong getting the SLA domain"
            else
              update_fileset = Rubrik::Api::Fileset.update_fileset('https://' + node['rubrik_host'], token, fileset_id, sla_domain_id, timeout)
              if update_fileset == false
                Chef::Log.error "Something went wrong updating the fileset"
              else
                Chef::Log.info ("Fileset created and updated succesfully")
              end
            end
          end
        end
      else
        if existing_fileset[0]['configuredSlaDomainName'] == node['rubrik_sla_domain']
          Chef::Log.info ("Fileset " + fileset + " found, and correctly provisioned, nothing to do")
        else
          Chef::Log.info ("Fileset " + fileset + " found, but SLA domain is not correct, correcting...")
          fileset_id = existing_fileset[0]['id']
          sla_domain_id = Rubrik::ConfMgmt::Helpers.get_sla_domain_id('https://' + node['rubrik_host'], token, node['rubrik_sla_domain'], timeout)
          if sla_domain_id.nil?
            Chef::Log.error "Something went wrong getting the SLA domain"
          else
            update_fileset = Rubrik::Api::Fileset.update_fileset('https://' + node['rubrik_host'], token, fileset_id, sla_domain_id, timeout)
            if update_fileset.nil?
              Chef::Log.error "Something went wrong updating the fileset"
            else
              Chef::Log.info ("Fileset updated succesfully")
            end
          end
        end
      end
    end
  end
  Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token, timeout)
  new_resource.updated_by_last_action(true)
end