use_inline_resources

action :set do
  token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
  if token.nil?
    Chef::Log.error ("Something went wrong connecting to the Rubrik cluster")
    exit
  end
  # refresh vcenter servers
  refresh_vcenters = Rubrik::Api::Vcenter.refresh_all_vcenters('https://' + node['rubrik_host'], token)
  if refresh_vcenters == false
    Chef::Log.error ("Something went wrong refreshing the vCenter inventories")
  else
    Chef::Log.info ("All vCenters refreshed successfully")
  end
  Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token)
  new_resource.updated_by_last_action(true)
end
