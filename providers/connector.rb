use_inline_resources

action set: do
  require 'openssl'
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

  # Determine the details for the platform running the Chef client. This
  # helps us genericise the remainder of the code
  case node['platform']
  when 'windows'
    download_uri = 'connector/RubrikBackupService.zip'
    target_file = 'C:\Windows\Temp\RubrikBackupService.zip'
    pkg_resource = :windows_package
    test_file = 'C:\Program Files\Rubrik\Rubrik Backup Service\rbs.exe'
  when 'centos','redhat','fedora','suse'
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
    windows_zipfile 'C:\Windows\Temp\RubrikBackupService.zip' do
      source 'C:\Windows\Temp\RubrikBackupService.zip'
      action :unzip
      overwrite true
      target_file = 'C:\Windows\Temp\\'
    end
  end

  # Install the software, using the relevant installer for the platform
  declare_resource(pkg_resource, target_file) do
    action :install
    not_if { ::File.exist?(test_file) }
  end

  if node['platform'] == 'windows'
    windows_service 'Rubrik Backup Service' do
      startup_type :automatic
      run_as_user node['rubrik_win_sa_user']
      run_as_password node['rubrik_win_sa_pass']
    end
  end
end