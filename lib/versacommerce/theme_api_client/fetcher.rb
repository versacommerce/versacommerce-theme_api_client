require 'json'
require 'http'
require 'active_support/core_ext/module/delegation'

module Versacommerce
  class ThemeAPIClient
    class Fetcher
      RecordNotFoundError = Class.new(StandardError)
      UnauthorizedError   = Class.new(StandardError)

      delegate :authorization, to: :client

      attr_reader :client

      def initialize(client)
        @client = client
      end

      def get(path)
        url = url_for_path(path)
        response = with_headers.get(url)
        handle_response(response, url)
      end

      def head(path)
        url = url_for_path(path)
        response = with_headers.head(url)
        handle_response(response, url)
      end

      def post(path, json = {})
        url = url_for_path(path)
        response = with_headers.post(url_for_path(path), json: json)
        handle_response(response, url)
      end

      def post_form(path, form_data = {})
        url = url_for_path(path)
        response = with_headers.post(url_for_path(path), form: form_data)
        handle_response(response, url)
      end

      def patch(path, json = {})
        url = url_for_path(path)
        response = with_headers.patch(url_for_path(path), json: json)
        handle_response(response, url)
      end

      def patch_form(path, form_data = {})
        url = url_for_path(path)
        response = with_headers.patch(url_for_path(path), form: form_data)
        handle_response(response, url)
      end

      def delete(path = {})
        url = url_for_path(path)
        response = with_headers.delete(url)
        handle_response(response, url)
      end

      private

      def handle_response(response, url)
        case response.status
        when ->(s) { s.unauthorized? }
          handle_unauthorized(response)
        when ->(s) { s.not_found? }
          raise RecordNotFoundError.new('Record for URL %s could not be found.' % url)
        else
          response
        end
      end

      def handle_unauthorized(response)
        if response.json.key?('error')
          raise UnauthorizedError.new('Could not be authorized: %s' % response.json['error'])
        else
          raise UnauthorizedError.new('You could not be authorized.')
        end
      end

      def url_for_path(path)
        '%s/%s' % [client.base_url, path.to_s]
      end

      def with_headers
        http_client = HTTP.headers(accept: 'application/json', 'Theme-Authorization' => authorization)

        # Apply SSL verification setting if explicitly disabled
        unless client.ssl_verify
          require 'openssl'
          ssl_context = OpenSSL::SSL::SSLContext.new
          ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE

          # Create new options with SSL context and rebuild HTTP client
          new_options = http_client.default_options.with_ssl_context(ssl_context)
          http_client = HTTP::Client.new(new_options)
        end

        http_client
      end
    end
  end
end

class HTTP::Response
  def json
    @json ||= if mime_type == 'application/json'
      JSON.parse(to_s)
    else
      {}
    end
  end
end
