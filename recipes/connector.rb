#
# Cookbook:: rubrik
# Recipe:: connector
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Installs the Rubrik connector
#
# Disable OpenSSL certificate verification - this assumes that the Rubrik
# cluster is presenting a self-signed certificate, which will cause the
# 'remote_file' resource to reject the download
require 'openssl'

# this block will skip over SSL verification, and suppress any errors
original_verbose = $VERBOSE
$VERBOSE = nil
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
$VERBOSE = original_verbose

# Determine the details for the platform running the Chef client. This
# helps us genericise the remainder of the code
case node['platform']
when 'windows'
  download_uri = 'connector/RubrikBackupService.zip'
  target_file = 'C:\Windows\Temp\RubrikBackupService.zip'
  pkg_resource = :windows_package
  test_file = 'C:\Program Files\Rubrik\Rubrik Backup Service\rbs.exe'
when 'centos', 'redhat', 'fedora', 'suse'
  download_uri = 'connector/rubrik-agent.x86_64.rpm'
  target_file = '/tmp/rubrik-agent.x86_64.rpm'
  pkg_resource = :rpm_package
  test_file = '/etc/rubrik/conf/agent_version'
when 'debian', 'ubuntu'
  download_uri = 'connector/rubrik-agent.x86_64.deb'
  target_file = '/tmp/rubrik-agent.x86_64.deb'
  pkg_resource = :dpkg_package
  test_file = '/etc/rubrik/conf/agent_version'
end

# Pull the installer down from the cluster
remote_file 'connector_installer' do
  source 'https://' + node['rubrik_host'] + '/' + download_uri
  path target_file
  action :create
  not_if { ::File.exist?(test_file) }
end

# For the Windows download we need to extract the ZIP
if node['platform'] == 'windows'
  windows_zipfile 'C:\Windows\Temp\\' do
    source 'C:\Windows\Temp\RubrikBackupService.zip'
    action :unzip
    overwrite true
  end
  target_file = 'C:\Windows\Temp\RubrikBackupService.msi'
end

# Install the software, using the relevant installer for the platform
declare_resource(pkg_resource, target_file) do
  action :install
  not_if { ::File.exist?(test_file) }
  notifies :run, 'execute[Setting Log On User For Rubrik Backup Service]', :immediately
end

execute 'Setting Log On User For Rubrik Backup Service' do
  command 'sc.exe config "Rubrik Backup Service" obj= ' + node['rubrik_win_sa_user'] + ' password= ' + node['rubrik_win_sa_pass']
  action :nothing
  sensitive true
  only_if { node['platform'] == 'windows' }
  only_if { defined?(node['rubrik_win_sa_user']) }
  only_if { defined?(node['rubrik_win_sa_pass']) }
end
