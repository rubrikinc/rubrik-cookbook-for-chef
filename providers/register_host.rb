use_inline_resources

action :get do
  token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
  if token.nil?
    Chef::Log.error 'Something went wrong connecting to the Rubrik cluster'
    exit
  end
  # check if host is registered
  is_registered = Rubrik::ConfMgmt::Core.check_host_registered('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ])
  if is_registered
    Chef::Log.info 'Host is already registered against the Rubrik cluster'
  else
    Chef::Log.info 'Host is not registered against the Rubrik cluster'
  end
  Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token)
  new_resource.updated_by_last_action(true)
end

action :set do
  token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
  if token.nil?
    Chef::Log.error 'Something went wrong connecting to the Rubrik cluster'
    exit
  end
  # check if host is registered
  is_registered = Rubrik::ConfMgmt::Core.check_host_registered('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ])
  if is_registered
    Chef::Log.info 'Host is already registered against the Rubrik cluster'
  else
    Chef::Log.info 'Host is not registered against the Rubrik cluster, registering now'
    register_host = Rubrik::ConfMgmt::Core.register_host('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ])
    if register_host
      Chef::Log.info 'Host registered successfully against the Rubrik cluster'
    else
      Chef::Log.error 'Something went wrong registering the host to the Rubrik cluster'
    end
  end
  Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token)
  new_resource.updated_by_last_action(true)
end
