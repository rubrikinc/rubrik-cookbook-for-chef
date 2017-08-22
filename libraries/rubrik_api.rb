# Rubrik REST module
module Rubrik
  # Import dependencies
  require 'uri'
  require 'net/http'
  require 'openssl'
  require 'json'
  module Api
    # Cluster management
    module Cluster
      # Get cluster details
      def self.get_cluster_id(hosturi, token)
        url = URI(hosturi + '/api/v1/cluster/me')
        response = Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['id']
      end

      # Get cluster software version
      def self.get_cluster_version(hosturi, token)
        url = URI(hosturi + '/api/v1/cluster/me/version')
        response = Helpers.http_get_request(url, token)
        body = JSON.parse(response.read_body)
        body['version']
      end

      # Get cluster API version
      def self.get_cluster_api_version(hosturi, token)
        url = URI(hosturi + '/api/v1/cluster/me/api_version')
        response = Helpers.http_get_request(url, token)
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
end
