# Rubrik REST module
module Rubrik
  # Import dependencies
  require 'uri'
  require 'net/http'
  require 'openssl'
  require 'json'
  # Direct API integrations
  module Api
    # Cluster management
    module Cluster
      # Get cluster details
      def self.get_cluster_id(hosturi, token)
        url = URI(hosturi + '/api/v1/cluster/me')
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['id']
      end

      # Get cluster software version
      def self.get_cluster_version(hosturi, token)
        url = URI(hosturi + '/api/v1/cluster/me/version')
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['version']
      end

      # Get cluster API version
      def self.get_cluster_api_version(hosturi, token)
        url = URI(hosturi + '/api/v1/cluster/me/api_version')
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['apiVersion']
      end
    end

    # vCenter operations
    module Vcenter
      # Get list of vCenter
      def self.get_all_vcenters(hosturi, token)
        uri = '/api/v1/vmware/vcenter?primary_cluster_id=local'
        url = URI(hosturi + uri)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end

      # Refresh single vCenter
      def self.refresh_vcenter(hosturi, token, vcenter_id)
        uri = '/api/v1/vmware/vcenter/' + vcenter_id + '/refresh'
        url = URI(hosturi + uri)
        response = Api::Helpers.http_post_request(url, token, nil)
        if response.code != '202'
          return 'error'
        end
        body = JSON.parse(response.read_body)
        body
      end

      # Refresh all vCenters
      def self.refresh_all_vcenters(hosturi, token)
        all_vcenters = Vcenter.get_all_vcenters(hosturi, token)
        result = true
        all_vcenters.each do |vcenter|
          refresh_task = Api::Vcenter.refresh_vcenter(hosturi, token, vcenter['id'])
          if refresh_task == 'error'
            result = false
          end
        end
        result
      end
    end

    # Fileset operations
    module Fileset
      # Get fileset summary
      def self.get_fileset_summary(hosturi, token)
        uri = '/api/v1/api/v1/fileset?primary_cluster_id=local&is_relic=false&limit=20000'
        url = URI(hosturi + uri)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end

      # Get fileset for host
      def self.get_filesets_for_host(hosturi, token, host_id)
        uri = '/api/v1/fileset?primary_cluster_id=local&is_relic=false&limit=20000&&host_id=' + host_id
        url = URI(hosturi + uri)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end

      # Get fileset for host by fileset name
      def self.get_fileset_by_name_for_host(hosturi, token, host_id, fileset_name)
        uri = '/api/v1/fileset?primary_cluster_id=local&is_relic=false&limit=20000&host_id=' + host_id + '&name=' + fileset_name
        url = URI(hosturi + uri)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end

      # Create a fileset
      def self.create_fileset(hosturi, token, host_id, fileset_template_id)
        uri = '/api/v1/fileset'
        url = URI(hosturi + uri)
        body = '{"hostId":"' + host_id + '","templateId":"' + fileset_template_id + '"}'
        response = Api::Helpers.http_post_request(url, token, body)
        if response.code != '201'
          return false
        end
        body = JSON.parse(response.read_body)
        body
      end

      # Update a fileset
      def self.update_fileset(hosturi, token, fileset_id, sla_domain_id)
        uri = '/api/v1/fileset/' + fileset_id
        url = URI(hosturi + uri)
        body = '{"configuredSlaDomainId":"' + sla_domain_id + '"}'
        response = Api::Helpers.http_patch_request(url, token, body)
        if response.code != '200'
          return false
        end
        body = JSON.parse(response.read_body)
        body
      end

      # Get detail for a fileset
      def self.get_fileset_detail(hosturi, token, fileset_id)
        uri = '/api/v1/fileset/' + fileset_id
        url = URI(hosturi + uri)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body
      end

      # Get missed snapshots for a fileset
      def self.get_missed_snapshots(hosturi, token, fileset_id)
        uri = '/api/v1/fileset/' + fileset_id + '/missed_snapshot'
        url = URI(hosturi + uri)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end

      # Search for a file in a fileset
      def self.get_search_for_file(hosturi, token, fileset_id, path)
        uri = '/api/v1/fileset/' + fileset_id + '/search?path=' + path
        url = URI.escape(hosturi + uri)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end

      # List all files and directories in a location in a fileset
      def self.get_browse_snapshot_files(hosturi, token, snapshot_id, path)
        uri = '/api/v1/fileset/snapshot/' + snapshot_id + '/browse?path=' + path
        url = URI.escape(hosturi + uri)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end

      # Get details about an asynchronous request
      def self.get_async_request_status(hosturi, token, request_id)
        uri = '/api/v1/fileset/request/' + request_id
        url = URI(hosturi + uri)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end
    end

    # Fileset Template operations
    module FilesetTemplate
      # Get fileset template summary
      def self.get_fileset_template_summary(hosturi, token)
        url = URI(hosturi + '/api/v1/fileset_template?primary_cluster_id=local')
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end

      # Get fileset template ID by name
      def self.get_fileset_template_by_name(hosturi, token, template_name)
        fileset_templates = FilesetTemplate.get_fileset_template_summary(hosturi, token)
        fileset_templates.each do |fileset_template|
          if fileset_template['name'] == template_name
            return fileset_template
          end
        end
        false
      end
    end

    # Linux hosts and Windows hosts
    module Host
      # Get all hosts
      def self.get_all_hosts(hosturi, token)
        url = URI(hosturi + '/api/v1/host?primary_cluster_id=local')
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end

      # Create a host
      def self.register_host(hosturi, token, hostname)
        url = URI(hosturi + '/api/v1/host')
        body = '{"hostname":"' + hostname + '","hasAgent":true}'
        response = Api::Helpers.http_post_request(url, token, body)
        if response.code != '201'
          return 'error'
        end
        body = JSON.parse(response.read_body)
        body['data']
      end

      # Refreshes a host
      def self.refresh_host(hosturi, token, host_id)
        url = URI(hosturi + '/api/v1/host/' + host_id + '/refresh')
        response = Api::Helpers.http_post_request(url, token, nil)
        if response.code != '200'
          return 'error'
        end
        true
      end
    end

    # SLA domain operations
    module SlaDomain
      # Get all SLA domains
      def self.get_all_sla_domains(hosturi, token)
        url = URI(hosturi + '/api/v1/sla_domain?primary_cluster_id=local')
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end

      # Get a single SLA domain by name
      def self.get_sla_domain_by_name(hosturi, token, sla_domain)
        url = URI(hosturi + '/api/v1/sla_domain?primary_cluster_id=local&name=' + sla_domain)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        if body['total'].zero?
          return 'error'
        end
        if body['total'] > 1
          body['data'].each do |ret_domain|
            if ret_domain['name'] == sla_domain
              ret_domain
            end
          end
        end
        body['data']
      end
    end

    # VM operations
    module Vmware
      # Get all VM summary
      def self.get_all_vms(hosturi, token)
        url = URI(hosturi + '/api/v1/vmware/vm?primary_cluster_id=local')
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end

      # Get summary of a single VM by name
      def self.get_single_vm_by_name(hosturi, token, vm_name)
        url = URI(hosturi + '/api/v1/vmware/vm?primary_cluster_id=local&name=' + vm_name)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        if body['total'].zero?
          return 'error'
        end

        if body['total'] > 0
          body['data'].each do |ret_vm|
            if ret_vm['name'] == vm_name
              return ret_vm
            end
          end
        end
        'error'
      end

      # Get summary of a single VM by name
      def self.get_vm_detail_by_id(hosturi, token, vm_id)
        url = URI(hosturi + '/api/v1/vmware/vm/' + vm_id)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body
      end

      # Get summary of a single VM by IP
      def self.get_single_vm_by_ip(hosturi, token, vm_ip)
        all_vms = Api::Vmware.get_all_vms(hosturi, token)
        all_vms.each do |vm|
          if vm['ipAddress'] == vm_ip
            return vm
          end
        end
        'error'
      end

      # Update VM
      def self.update_vm_config(hosturi, token, vm_id, new_config)
        url = URI(hosturi + '/api/v1/vmware/vm/' + vm_id)
        response = Api::Helpers.http_patch_request(url, token, new_config)
        if response.code != '200'
          return 'error'
        end
        body = JSON.parse(response.read_body)
        body
      end

      # Take on-demand snapshot
      def self.take_od_snapshot(hosturi, token, vm_id, sla_id)
        url = URI(hosturi + '/api/v1/vmware/vm/' + vm_id + '/snapshot')
        body = if sla_id.nil?
                 '{}'
               else
                 '{"slaId":"' + sla_id + '"}'
               end
        response = Api::Helpers.http_post_request(url, token, body)
        if response.code != '202'
          return 'error'
        end
        body = JSON.parse(response.read_body)
        body
      end
    end

    # SQL Server
    module Mssql
      # Get all SQL instances for a host
      def self.get_sql_instances_by_host(hosturi, token, host_id)
        url = URI(hosturi + '/api/v1/mssql/instance?primary_cluster_id=local&root_id='+host_id)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end
      # Get all SQL databases for a instance
      def self.get_sql_dbs_by_instance(hosturi, token, instance_id)
        url = URI(hosturi + '/api/v1/mssql/db?primary_cluster_id=local&instance_id='+instance_id)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end
      # Update a SQL instance
      def self.update_sql_instance_config(hosturi, token, instance_id, new_config)
        url = URI(hosturi + '/api/v1/mssql/instance/'+instance_id)
        response = Api::Helpers.http_patch_request(url, token, new_config)
        if response.code != '200'
          'error'
        end
        body = JSON.parse(response.read_body)
        body
      end
      # Update a SQL database
      def self.update_sql_db_config(hosturi, token, db_id, new_config)
        url = URI(hosturi + '/api/v1/mssql/db/'+db_id)
        response = Api::Helpers.http_patch_request(url, token, new_config)
        if response.code != '200'
          'error'
        end
        body = JSON.parse(response.read_body)
        body
      end
    end

    # Nutanix
    module Nutanix
      # Get all VM summary
      def self.get_all_vms(hosturi, token)
        url = URI(hosturi + '/api/v1/nutanix/vm?primary_cluster_id=local')
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end

      # Get summary of a single VM by name
      def self.get_single_vm_by_name(hosturi, token, vm_name)
        url = URI(hosturi + '/api/v1/nutanix/vm?primary_cluster_id=local&name=' + vm_name)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        if body['total'].zero?
          'error'
        end
        if body['total'] > 1
          body['data'].each do |ret_vm|
            if ret_vm['name'] == vm_name
              ret_vm
            end
          end
        end
        body['data']
      end

      # Get summary of a single VM by IP
      def self.get_single_vm_by_ip(hosturi, token, vm_ip)
        all_vms = Api::Nutanix.get_all_vms(hosturi, token)
        all_vms.each do |vm|
          if vm['ipAddress'] == vm_ip
            return vm
          end
        end
        'error'
      end

      # Update VM
      def self.update_vm_config(hosturi, token, vm_id, new_config)
        url = URI(hosturi + '/api/v1/nutanix/vm/' + vm_id)
        response = Api::Helpers.http_patch_request(url, token, new_config)
        if response.code != '200'
          'error'
        end
        body = JSON.parse(response.read_body)
        body
      end
    end

    # Hyper-V
    module HyperV
      # Get all VM summary
      def self.get_all_vms(hosturi, token)
        url = URI(hosturi + '/api/v1/hyperv/vm?primary_cluster_id=local')
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end

      # Get summary of a single VM by name
      def self.get_single_vm_by_name(hosturi, token, vm_name)
        url = URI(hosturi + '/api/v1/hyperv/vm?primary_cluster_id=local&name=' + vm_name)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        if body['total'].zero?
          return 'error'
        end
        if body['total'] > 1
          body['data'].each do |ret_vm|
            if ret_vm['name'] == vm_name
              ret_vm
            end
          end
        end
        body['data']
      end

      # Get summary of a single VM by IP
      def self.get_single_vm_by_ip(hosturi, token, vm_ip)
        all_vms = Api::HyperV.get_all_vms(hosturi, token)
        all_vms.each do |vm|
          if vm['ipAddress'] == vm_ip
            return vm
          end
        end
        'error'
      end

      # Update VM
      def self.update_vm_config(hosturi, token, vm_id, new_config)
        url = URI(hosturi + '/api/v1/hyperv/vm/' + vm_id)
        response = Api::Helpers.http_patch_request(url, token, new_config)
        if response.code != '200'
          return 'error'
        end
        body = JSON.parse(response.read_body)
        body
      end
    end

    # Organisations
    module Organizations
      # Get all organization summary
      def self.get_all_organizations(hosturi, token)
        url = URI(hosturi + '/api/internal/organization')
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end

      # Get summary of a single organization by name
      def self.get_single_org_by_name(hosturi, token, org_name)
        all_orgs = Api::Organizations.get_all_organizations(hosturi, token)
        all_orgs.each do |org|
          return org if org['name'] == org_name
        end
      end

      # Get a list of managable objects for an organization
      def self.get_org_managable_objects(hosturi, token, org_id)
        url = URI(hosturi + '/api/internal/authorization/role/organization?principals='+org_id+'&organization_id='+org_id)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data'][0]['privileges']['manageResource']
      end

      # Add an object to an organization
      def self.add_object_to_org(hosturi, token, object_id, org_id)
        managed_objects = Api::Organizations.get_org_managable_objects(hosturi,token,org_id)
        managed_objects.each do |resource_id|
          return 'object already in organization' if resource_id == object_id
        end
        body = {
          'principals' => [org_id], 'organizationId' => org_id,
          'privileges' => { 'manageCluster' => [], 'manageResource' => [object_id],
            'useSla' => [], 'manageSla' => [] }
        }
        url = URI(hosturi + '/api/internal/authorization/role/organization')
        response = Api::Helpers.http_post_request(url, token, JSON.dump(body))
        return 'error' if response.code != '200'

        body = JSON.parse(response.read_body)
        body
      end
    end

    # Session management
    module Session
      # Create new session
      def self.post_session(hosturi, username, password)
        url = URI(hosturi + '/api/v1/session')
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new(url)
        request.basic_auth(username, password)
        request['Content-Type'] = 'application/json'
        request.body = '{"username":"' + username + '","password":"' + password + '"}'
        response = http.request(request)
        body = JSON.parse(response.read_body)
        body['token']
      end

      # Delete session
      def self.delete_session(hosturi, token)
        url = URI(hosturi + '/api/v1/session/me')
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Delete.new(url)
        request['Content-Type'] = 'application/json'
        request['Authorization'] = 'Bearer ' + token
        response = http.request(request)
        response
      end
    end

    # Helper functions
    module Helpers
      # GET request
      def self.http_get_request(hosturl, token)
        http = Net::HTTP.new(hosturl.host, hosturl.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(hosturl)
        request['Accept'] = 'application/json'
        request['Authorization'] = 'Bearer ' + token
        response = http.request(request)
        response
      end

      # POST request
      def self.http_post_request(hosturl, token, body)
        # foo
        http = Net::HTTP.new(hosturl.host, hosturl.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new(hosturl)
        request['Accept'] = 'application/json'
        request['Content-Type'] = 'application/json'
        request['Authorization'] = 'Bearer ' + token
        request.body = body
        response = http.request(request)
        response
      end

      # PUT request
      def self.http_put_request(hosturl, token, body)
        http = Net::HTTP.new(hosturl.host, hosturl.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Put.new(hosturl)
        request['Content-Type'] = 'application/json'
        request['Accept'] = 'application/json'
        request['Authorization'] = 'Bearer ' + token
        request.body = body
        response = http.request(request)
        response
      end

      # DELETE request
      def self.http_delete_request(hosturl, token)
        http = Net::HTTP.new(hosturl.host, hosturl.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Delete.new(hosturl)
        request['Content-Type'] = 'application/json'
        request['Accept'] = 'application/json'
        request['Authorization'] = 'Bearer ' + token
        request.body = body
        response = http.request(request)
        response
      end

      # PATCH request
      def self.http_patch_request(hosturl, token, body)
        http = Net::HTTP.new(hosturl.host, hosturl.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Patch.new(hosturl)
        request['Content-Type'] = 'application/json'
        request['Accept'] = 'application/json'
        request['Authorization'] = 'Bearer ' + token
        request.body = body
        response = http.request(request)
        response
      end

      # Test credential set
      def self.test_credentials(hosturl, credentials)
        uri = '/api/v1/cluster/me'
        url = URI(hosturl + uri)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(url)
        request.basic_auth(credentials[0], credentials[1])
        request['Accept'] = 'application/json'
        response = http.request(request)
        throw 'Invalid credentials detected, please retry' if response.code == '422'
        response
      end
    end
  end

  # Configuration Management functions
  module ConfMgmt
    # Core Configuration Management functions
    module Core
      # Get the SLA domain for a given VM
      def self.get_vmware_vm_sla_domain(hosturi, token, vm_info)
        vm_data = Api::Vmware.get_single_vm_by_name(hosturi, token, vm_info[0])
        if vm_data == 'error'
          vm_data = Api::Vmware.get_single_vm_by_ip(hosturi, token, vm_info[1])
        end
        if vm_data == 'error'
          raise('VMware Virtual Machine with name ' + vm_info[0] + ' or IP address ' + vm_info[1] + ' not found.')
        end

        conf_sla_domain_name = vm_data['configuredSlaDomainName']
        if conf_sla_domain_name != 'Inherit'
          return conf_sla_domain_name
        end
        effective_sla_domain_name = vm_data['effectiveSlaDomainName']
        effective_sla_domain_name
      end

      # Set the SLA domain for a given VM
      def self.set_vmware_vm_sla_domain(hosturi, token, vm_info, sla_domain)
        vm_id = ConfMgmt::Helpers.get_vmware_vm_id(hosturi, token, vm_info)
        sla_domain_id = ConfMgmt::Helpers.get_sla_domain_id(hosturi, token, sla_domain)
        if sla_domain_id == 'error'
          raise('SLA Domain with name ' + sla_domain + ' not found.')
        end
        update_props = '{"configuredSlaDomainId": "' + sla_domain_id + '"}'
        update_sla_task = Api::Vmware.update_vm_config(hosturi, token, vm_id, update_props)
        if update_sla_task == 'error'
          raise('Something went wrong adding ' + vm_info[0] + ' to SLA domain ' + sla_domain)
        end
        update_sla_task
      end

      # Trigger an on-demand snapshot
      def self.take_od_snapshot(hosturi, token, vm_id, sla_id)
        od_snapshot_task = Api::Vmware.take_od_snapshot(hosturi, token, vm_id, sla_id)
        if od_snapshot_task == 'error'
          raise('Something went wrong with the on-demand snapshot')
        end
        od_snapshot_task
      end

      # Check if host is registered with cluster
      def self.check_host_registered(hosturi, token, host_info)
        all_hosts = Rubrik::Api::Host.get_all_hosts(hosturi, token)
        all_hosts.each do |hostdata|
          if host_info.include? hostdata['hostname']
            return true
          end
        end
        false
      end

      # Register host against cluster
      def self.register_host(hosturi, token, host_info)
        host_info.each do |host_alias|
          register_host = Rubrik::Api::Host.register_host(hosturi, token, host_alias)
          if register_host != 'error'
            return true
          end
        end
        false
      end

      # Get Host ID
      def self.get_registered_host_id(hosturi, token, host_info)
        all_hosts = Rubrik::Api::Host.get_all_hosts(hosturi, token)
        all_hosts.each do |hostdata|
          if host_info.include? hostdata['hostname']
            return hostdata['id']
          end
        end
        false
      end

      # Get SQL Host level SLA
      def self.get_all_sql_instances_protection(hosturi, token, host_id)
        sql_instances = Rubrik::Api::Mssql.get_sql_instances_by_host(hosturi, token, host_id)
        output = Hash.new
        sql_instances.each do |sql_instance|
          output[sql_instance['name']] = sql_instance['configuredSlaDomainName']
        end
        output
      end

      # Update SQL Instance Protection
      def self.update_sql_instance_protection(hosturi, token, instance_id, sla_domain, log_backup_frequency, log_retention_hours)
        sla_domain_id = ConfMgmt::Helpers.get_sla_domain_id(hosturi, token, sla_domain)
        new_config = '{"configuredSlaDomainId":"' + sla_domain_id + '","logBackupFrequencyInSeconds":' + log_backup_frequency.to_s + ',"logRetentionHours":' + log_retention_hours.to_s + ',"copyOnly":false}'
        update_task = Rubrik::Api::Mssql.update_sql_instance_config(hosturi, token, instance_id, new_config)
        update_task
      end

      # Get SQL Instance ID by host ID and instance name
      def self.get_sql_instance_id_by_name_and_host_id(hosturi, token, instance_name, host_id)
        sql_instances = Rubrik::Api::Mssql.get_sql_instances_by_host(hosturi, token, host_id)
        sql_instances.each do |sql_instance|
          if sql_instance['name'] = instance_name
            return sql_instance['id']
          end
        end
        false
      end

      # Get VMware VM consistency settings
      def self.get_vmware_vm_consistency(hosturi, token, vm_info)
        vm_id = ConfMgmt::Helpers.get_vmware_vm_id(hosturi, token, vm_info)
        vm_data = Rubrik::Api::Vmware.get_vm_detail_by_id(hosturi, token, vm_id)
        vm_data['snapshotConsistencyMandate']
      end

      # Update VMware VM consistency settings
      def self.set_vmware_vm_consistency(hosturi, token, vm_info, consistency)
        vm_id = ConfMgmt::Helpers.get_vmware_vm_id(hosturi, token, vm_info)
        update_props = '{"snapshotConsistencyMandate": "' + consistency + '"}'
        update_consistency = Api::Vmware.update_vm_config(hosturi, token, vm_id, update_props)
        if update_consistency == 'error'
          raise('Something went wrong updating consistency for ' + vm_info[0] + ' to ' + consistency)
        end
        update_consistency
      end
    end

    # Helper functions
    module Helpers
      # Get the VM ID for a given VM
      def self.get_vmware_vm_id(hosturi, token, vm_info)
        vm_data = Api::Vmware.get_single_vm_by_name(hosturi, token, vm_info[0])
        if vm_data == 'error'
          vm_data = Api::Vmware.get_single_vm_by_ip(hosturi, token, vm_info[1])
        end
        if vm_data == 'error'
          raise('VMware Virtual Machine with name ' + vm_info[0] + ' or IP address ' + vm_info[1] + ' not found.')
        end

        vm_data['id']
      end

      # Get the SLA domain ID for a given SLA domain
      def self.get_sla_domain_id(hosturi, token, sla_domain)
        sla_domain_data = Api::SlaDomain.get_sla_domain_by_name(hosturi, token, sla_domain)
        if sla_domain_data == 'error'
          raise('SLA Domain with name ' + sla_domain + ' not found.')
        end
        sla_domain_data[0]['id']
      end
    end
  end
end

