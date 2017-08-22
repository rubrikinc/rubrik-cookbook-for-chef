use_inline_resources

action :list do
  token = Rubrik::Api::Session.post_session(node['rubrik_host'], node['rubrik_username'], node['rubrik_password'])
  # get cluster details
  puts "\r\nCluster ID: " + Rubrik::Api::Cluster.get_cluster_id(node['rubrik_host'], token)
  puts "\r\nCluster Version: " + Rubrik::Api::Cluster.get_cluster_version(node['rubrik_host'], token)
  puts "\r\nCluster API version: " + Rubrik::Api::Cluster.get_cluster_api_version(node['rubrik_host'], token)
  new_resource.updated_by_last_action(true)
end
