use_inline_resources

action :get do
  token = Rubrik::Api::Session.post_session('https://' + node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
  if token.nil?
    Chef::Log.error "Something went wrong connecting to the Rubrik cluster"
    exit
  end
  # get current SLA domain
  host_id = Rubrik::ConfMgmt::Core.get_registered_host_id('https://' + node['rubrik_host'], token, [ node['hostname'], node['ipaddress'] ])
  if host_id.nil?
    Chef::Log.info ("Host is not registered against the Rubrik cluster")
  else
    Chef::Log.info ("Host Current host ID is: " + host_id)
    host_filesets = Rubrik::Api::Fileset.get_filesets_for_host('https://' + node['rubrik_host'], token, host_id)
    Chef::Log.info ("This host has " + host_filesets.count.to_s + " filesets currently assigned")
    if host_filesets.count > 0
      for host_fileset in host_filesets
        Chef::Log.info ("Fileset '" + host_fileset['name'] + "' found, with ID: " + host_fileset['id'] + ", and SLA domain: " + host_fileset['configuredSlaDomainName'])
      end
    end
  end
  Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token)
  new_resource.updated_by_last_action(true)
end