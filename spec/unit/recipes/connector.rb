#
# Cookbook:: rubrik
# Spec:: connector
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'rubrik::connector' do
  context 'When all attributes are default, on an Ubuntu 16.04' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'downloads the software' do
      expect(chef_run).to create_remote_file('/tmp/rubrik-agent.x86_64.deb')
    end

    it 'installs the connector' do
      expect(chef_run).to install_dpkg_package('/tmp/rubrik-agent.x86_64.deb')
    end
  end

  context 'When all attributes are default, on an CentOS 6.9' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.9')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'downloads the software' do
      expect(chef_run).to create_remote_file('/tmp/rubrik-agent.x86_64.rpm')
    end

    it 'installs the connector' do
      expect(chef_run).to install_rpm_package('/tmp/rubrik-agent.x86_64.rpm')
    end
  end

  context 'When all attributes are default, on an Windows 2012R2' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'downloads the software' do
      expect(chef_run).to create_remote_file('C:\Windows\Temp\RubrikBackupService.zip')
    end

    it 'extracts the software' do
      expect(chef_run).to unzip_windows_zipfile_to('C:\Windows\Temp\\')
    end

    it 'installs the connector' do
      expect(chef_run).to install_windows_package('C:\Windows\Temp\RubrikBackupService.msi')
    end
  end
end
