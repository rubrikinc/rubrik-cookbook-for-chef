use_inline_resources

action :get do
  token = Rubrik::Api::Session.post_session(node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
  if token.nil?
    Chef::Log.error "Something went wrong connecting to the Rubrik cluster"
    exit
  end
  # get cluster details
  Chef::Log.info ("Cluster ID: " + Rubrik::Api::Cluster.get_cluster_id(node['rubrik_host'], token))
  Chef::Log.info ("Cluster Version: " + Rubrik::Api::Cluster.get_cluster_version(node['rubrik_host'], token))
  Chef::Log.info ("Cluster API version: " + Rubrik::Api::Cluster.get_cluster_api_version(node['rubrik_host'], token))
  # Delete Session
  Rubrik::Api::Session.delete_session(node['rubrik_host'], token)
  new_resource.updated_by_last_action(true)
end
