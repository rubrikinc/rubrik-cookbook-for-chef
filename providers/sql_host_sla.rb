use_inline_resources

action :get do
    token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
    if token.nil?
      Chef::Log.error "Something went wrong connecting to the Rubrik cluster"
      exit
    end
    host_id = Rubrik::ConfMgmt::Core.get_registered_host_id('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ])
    if host_id == false
      Chef::Log.info ("Host is not registered against the Rubrik cluster")
    else
      current_protection = Rubrik::ConfMgmt::Core.get_all_sql_instances_protection('https://' + node['rubrik_host'], token, host_id)
      if current_protection.length == 0
        Chef::Log.info ("No SQL Server instances found on this host")
      else
        current_protection.each do |key, value|
          Chef::Log.info ("SQL instance "+key+" protection is: "+value)
        end
      end
    end
    Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token)
    new_resource.updated_by_last_action(true)
  end

action :set do
    token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
    if token.nil?
      Chef::Log.error "Something went wrong connecting to the Rubrik cluster"
      exit
    end
    host_id = Rubrik::ConfMgmt::Core.get_registered_host_id('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ])
    if host_id.nil?
      Chef::Log.info ("Host is not registered against the Rubrik cluster")
      break
    else
      # protect host
      current_protection = Rubrik::ConfMgmt::Core.get_all_sql_instances_protection('https://' + node['rubrik_host'], token, host_id)
      if current_protection.length == 0
        Chef::Log.info ("No SQL Server instances found on this host")
      else
        current_protection.each do |key, value|
          if value != node['rubrik_sla_domain']
            instance_id = Rubrik::ConfMgmt::Core.get_sql_instance_id_by_name_and_host_id('https://' + node['rubrik_host'], token, key, host_id)
            protect_task = Rubrik::ConfMgmt::Core.update_sql_instance_protection('https://' + node['rubrik_host'], token, instance_id, node['rubrik_sla_domain'], new_resource.log_backup_freq_minutes * 60, new_resource.log_retention_days * 24)
            if protect_task == 'error'
              Chef::Log.error ("Something went wrong protecting SQL instance "+key+" with SLA domain: "+node['rubrik_sla_domain'])
            else
              Chef::Log.info ("SQL instance "+key+" protection updated to SLA domain: "+node['rubrik_sla_domain'])
            end
          else
            Chef::Log.info ("SQL instance "+key+" already protected with SLA domain: "+node['rubrik_sla_domain'])
          end
        end
      end
    end
    Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token)
    new_resource.updated_by_last_action(true)
end