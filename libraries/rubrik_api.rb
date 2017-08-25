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

    # Fileset operations
    module Fileset
      # Get fileset summary
      def self.get_fileset_summary(hosturi, token)
        uri = '/api/v1/api/v1/fileset'
        url = URI(hosturi + uri)
        response = Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end
      # Get detail for a fileset
      def self.get_fileset_detail(hosturi, token, fileset_id)
        uri = '/api/v1/fileset/' + fileset_id
        url = URI(hosturi + uri)
        response = Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
      end
      # Get missed snapshots for a fileset
      def self.get_missed_snapshots(hosturi, token, fileset_id)
        uri = '/api/v1/fileset/' + fileset_id + '/missed_snapshot'
        url = URI(hosturi + uri)
        response = Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
      end
      # Search for a file in a fileset
      def self.get_search_for_file(hosturi, token, fileset_id, path)
        uri = '/api/v1/fileset/' + fileset_id + '/search?path=' + path
        url = URI.escape(hosturi + uri)
        response = Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
      end
      # List all files and directories in a location in a fileset
      def self.get_browse_snapshot_files(hosturi, token, snapshot_id, path)
        uri = '/api/v1/fileset/snapshot/' + snapshot_id + '/browse?path=' + path
        url = URI.escape(hosturi + uri)
        response = Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
      end
      # Get details about an asynchronous request
      def self.get_async_request_status(hosturi, token, request_id)
        uri = '/api/v1/fileset/request/' + request_id
        url = URI(hosturi + uri)
        response = Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
      end
    end

    # Fileset Template operations
    module FilesetTemplate
      # Get fileset template summary
      def self.get_fileset_template_summary(hosturi, token)
        url = URI(hosturi + '/api/v1/fileset_template')
        response = Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['data']
      end
    end

    # SLA domain operations
    module SlaDomain
      # Get all SLA domains
      def self.get_all_sla_domains(hosturi, token)
        url = URI(hosturi + '/api/v1/sla_domain?primary_cluster_id=local')
      end
      # Get a single SLA domain by name
      def self.get_sla_domain_by_name(hosturi, token, sla_domain)
        url = URI(hosturi + '/api/v1/sla_domain?primary_cluster_id=local&name=' + sla_domain)
        response = Api::Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        if body['total'] != 1
          return 'error'
        end
        body['data']
      end
    end

    # VM operations
    module VM
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
        if body['total'] != 1
          return 'error'
        end
        body['data']
      end
      # Get summary of a single VM by IP
      def self.get_single_vm_by_ip(hosturi, token, vm_ip)
        all_vms = Api::VM::get_all_vms(hosturi, token)
        for vm in all_vms
          if vm['ipAddress'] == vm_ip
            return vm
          end
        end
      end
      # Update VM
      def self.update_vm_config(hosturi, token, vm_id, new_config)
        url = URI(hosturi + '/api/v1/vmware/vm/' + vm_id)
        response = Api::Helpers.http_patch_request(url, token, new_config)
        if response.code != '200'
          return 'Something went wrong'
        end
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
        request.body = '{"username":"'+username+'","password":"'+password+'"}'
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
        if response.code == '204'
          puts 'Session deleted'
        end
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
        # foo
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
        if response.code == '422'
          puts 'Invalid credentials detected, please retry'
          exit
        end
      end
    end
  end
  # Configuration Management functions
  module ConfMgmt
    module Core
      # Get the SLA domain for a given VM
      def self.get_vm_sla_domain(hosturi, token, vm_info)
        vm_data = Api::VM.get_single_vm_by_name(hosturi, token, vm_info[0])
        if vm_data == 'error'
          vm_data = Api::VM.get_single_vm_by_ip(hosturi, token, vm_info[1])
        end
        vm_data[0]['configuredSlaDomainName']
      end
      # Set the SLA domain for a given VM
      def self.set_vm_sla_domain(hosturi, token, vm_info, sla_domain)
        vm_id = ConfMgmt::Helpers.get_vm_id(hosturi, token, vm_info)
        sla_domain_id = ConfMgmt::Helpers.get_sla_domain_id(hosturi, token, sla_domain)
        update_props = '{"configuredSlaDomainId": "' + sla_domain_id + '"}'
        update_sla_task = Api::VM.update_vm_config(hosturi, token, vm_id, update_props)
        update_sla_task
      end
    end
    module Helpers
      # Get the VM ID for a given VM
      def self.get_vm_id(hosturi, token, vm_info)
        vm_data = Api::VM.get_single_vm_by_name(hosturi, token, vm_info[0])
        if vm_data == 'error'
          vm_data = Api::VM.get_single_vm_by_ip(hosturi, token, vm_info[1])
        end
        vm_data[0]['id']
      end
      # Get the SLA domain ID for a given SLA domain
      def self.get_sla_domain_id(hosturi, token, sla_domain)
        sla_domain_data = Api::SlaDomain.get_sla_domain_by_name(hosturi, token, sla_domain)
        sla_domain_data[0]['id']
      end
    end
  end
end
