use_inline_resources

# checks the organisation ownership of an object
action :get do
  if node['rubrik_org_name'] and node['rubrik_org_name']!='Global'
    token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
    if token.nil?
      Chef::Log.error 'Something went wrong connecting to the Rubrik cluster'
      exit
    end
    assigned_to_org = false
    org_id = Rubrik::Api::Organizations.get_single_org_by_name('https://' + node['rubrik_host'], token, node['rubrik_org_name'])['id']
    if org_id
      org_objects = Rubrik::Api::Organizations.get_org_managable_objects('https://' + node['rubrik_host'], token, org_id)
      case new_resource.object_type
      when 'vmwarevm'
        vm_id = Rubrik::ConfMgmt::Helpers.get_vmware_vm_id('https://'+node['rubrik_host'], token, [node['hostname'],node['ipaddress']])
        org_objects.each do |org_object|
          assigned_to_org = true if org_object == vm_id
        end
      when 'host'
        host_id = Rubrik::ConfMgmt::Core.get_registered_host_id('https://'+node['rubrik_host'],token,[node['hostname'],node['ipaddress']])
        org_objects.each do |org_object|
          assigned_to_org = true if org_object == host_id
        end
      else
        Chef::Log.error 'Object type was not recognised'
      end
      if !object_id
        Chef::Log.error 'Object ID not found on Rubrik system'
      else
        if assigned_to_org
          Chef::Log.info 'This object is currently assigned to Organization with name: ' + node['rubrik_org_name']
        else
          Chef::Log.info 'This object is not currently assigned to Organization with name: ' + node['rubrik_org_name']
        end
      end
    else
      Chef::Log.error 'No organization named ' + node['rubrik_org_name'] + ' could be found'
    end
    Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token)
  else
    Chef::Log.error 'Organization not passed, or value of node[\'rubrik_org_name\'] was \'Global\''
  end
  new_resource.updated_by_last_action(true)
end

# adds an object to an organisation
action :set do
  if node['rubrik_org_name'] and node['rubrik_org_name']!='Global'
    token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
    if token.nil?
      Chef::Log.error 'Something went wrong connecting to the Rubrik cluster'
      exit
    end
    org_id = Rubrik::Api::Organizations.get_single_org_by_name('https://' + node['rubrik_host'], token, node['rubrik_org_name'])['id']
    if org_id
      assigned_to_org = false
      org_objects = Rubrik::Api::Organizations.get_org_managable_objects('https://' + node['rubrik_host'], token, org_id)
      case new_resource.object_type
      when 'vmwarevm'
        object_id = Rubrik::ConfMgmt::Helpers.get_vmware_vm_id('https://'+node['rubrik_host'], token, [node['hostname'],node['ipaddress']])
        org_objects.each do |org_object|
          assigned_to_org = true if org_object == object_id
        end
      when 'host'
        object_id = Rubrik::ConfMgmt::Core.get_registered_host_id('https://'+node['rubrik_host'],token,[node['hostname'],node['ipaddress']])
        org_objects.each do |org_object|
          assigned_to_org = true if org_object == object_id
        end
      else
        Chef::Log.error 'Object type was not recognised'
      end
      if assigned_to_org
        Chef::Log.info 'This object is already assigned to Organization with name: ' + node['rubrik_org_name'] + ', nothing to do'
      else
        if !object_id
          Chef::Log.error 'Object ID not found on Rubrik system'
        else
          assign_to_org = Rubrik::Api::Organizations.add_object_to_org('https://' + node['rubrik_host'], token, object_id, org_id)
          if assign_to_org != 'error'
            Chef::Log.info 'Assigned object to Organization with name: ' + node['rubrik_org_name']
          else
            Chef::Log.error 'Something went wrong adding object to Organization with name: ' + node['rubrik_org_name']
          end
        end
      end
    else
      Chef::Log.error 'No organization named ' + node['rubrik_org_name'] + ' could be found'
    end
    Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token)
  else
    Chef::Log.error 'Organization not passed, or value of node[\'rubrik_org_name\'] was \'Global\''
  end
  new_resource.updated_by_last_action(true)
end
