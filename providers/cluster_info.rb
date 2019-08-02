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
  # get cluster details
  Chef::Log.info ("Cluster ID: " + Rubrik::Api::Cluster.get_cluster_id('https://' + node['rubrik_host'], token, timeout))
  Chef::Log.info ("Cluster Version: " + Rubrik::Api::Cluster.get_cluster_version('https://' + node['rubrik_host'], token, timeout))
  Chef::Log.info ("Cluster API version: " + Rubrik::Api::Cluster.get_cluster_api_version('https://' + node['rubrik_host'], token, timeout))
  # Delete Session
  Rubrik::Api::Session.delete_session('https://' + node['rubrik_host'], token, timeout)
  new_resource.updated_by_last_action(true)
end
