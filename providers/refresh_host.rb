use_inline_resources

action :set do
  token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
  if token.nil?
    Chef::Log.error ("Something went wrong connecting to the Rubrik cluster")
    exit
  end
  # check if host is registered
  host_id = Rubrik::ConfMgmt::Core.get_registered_host_id('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ])
  if host_id
    refresh_host = Rubrik::Api::Host.refresh_host('https://' + node['rubrik_host'], token, host_id)
    if refresh_host == true
      Chef::Log.info ("Host refreshed on the Rubrik cluster")
    else
      Chef::Log.error ("Something went wrong refreshing the host on the Rubrik cluster")
    end
  else
    Chef::Log.info ("Host is not registered against the Rubrik cluster, unable to refresh")
  end
  Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token)
  new_resource.updated_by_last_action(true)
end
