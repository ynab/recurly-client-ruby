module RecurlyV2
  # The API class handles all requests to the RecurlyV2 API. While most of its
  # functionality is leveraged by the Resource class, it can be used directly,
  # as well.
  #
  # Requests are made with methods named after the four main HTTP verbs
  # recognized by the RecurlyV2 API.
  #
  # @example
  #   RecurlyV2::API.get 'accounts'             # => #<Net::HTTPOK ...>
  #   RecurlyV2::API.post 'accounts', xml_body  # => #<Net::HTTPCreated ...>
  #   RecurlyV2::API.put 'accounts/1', xml_body # => #<Net::HTTPOK ...>
  #   RecurlyV2::API.delete 'accounts/1'        # => #<Net::HTTPNoContent ...>
  class API
    require 'recurly_v2/api/errors'
    require 'openssl'

    @@base_uri = "https://api.recurly.com/v2/"
    @@valid_domains = [".recurly.com"]

    RECURLY_API_VERSION = '2.29'

    FORMATS = Helper.hash_with_indifferent_read_access(
      'pdf' => 'application/pdf',
      'xml' => 'application/xml'
    )

    class << self
      # Additional HTTP headers sent with each API call
      # @return [Hash{String => String}]
      def headers
        @headers ||= { 'Accept' => accept, 'User-Agent' => user_agent, 'X-Api-Version' => RECURLY_API_VERSION }
      end

      # @return [String, nil] Accept-Language header value
      def accept_language
        headers['Accept-Language']
      end

      # @param [String] language Accept-Language header value
      def accept_language=(language)
        headers['Accept-Language'] = language
      end

      # @return [Net::HTTPOK, Net::HTTPResponse]
      # @raise [ResponseError] With a non-2xx status code.
      def head uri, params = {}, options = {}
        request :head, uri, { :params => params || {} }.merge(options)
      end

      # @return [Net::HTTPOK, Net::HTTPResponse]
      # @raise [ResponseError] With a non-2xx status code.
      def get uri, params = {}, options = {}
        request :get, uri, { :params => params || {} }.merge(options)
      end

      # @return [Net::HTTPCreated, Net::HTTPResponse]
      # @raise [ResponseError] With a non-2xx status code.
      def post uri, body = nil, options = {}
        request :post, uri, { :body => body.to_s }.merge(options)
      end

      # @return [Net::HTTPOK, Net::HTTPResponse]
      # @raise [ResponseError] With a non-2xx status code.
      def put uri, body = nil, options = {}
        request :put, uri, { :body => body.to_s }.merge(options)
      end

      # @return [Net::HTTPNoContent, Net::HTTPResponse]
      # @raise [ResponseError] With a non-2xx status code.
      def delete uri, body = nil, options = {}
        request :delete, uri, options
      end

      # @return [URI::Generic]
      def base_uri
        URI.parse @@base_uri.sub('api', RecurlyV2.subdomain)
      end

      def validate_uri!(uri)
        domain = @@valid_domains.detect { |d| uri.host.end_with?(d) }
        unless domain
          raise ArgumentError, "URI #{uri} is invalid. You may only make requests to a RecurlyV2 domain."
        end
      end

      # @return [String]
      def user_agent
        agent_string = "RecurlyV2/#{Version}; #{RUBY_DESCRIPTION};"

        if OpenSSL.const_defined?(:OPENSSL_VERSION)
          "#{agent_string} #{OpenSSL::OPENSSL_VERSION}"
        elsif OpenSSL.const_defined?(:OPENSSL_LIBRARY_VERSION)
          "#{agent_string} #{OpenSSL::OPENSSL_LIBRARY_VERSION}"
        else
          agent_string
        end
      end

      private

      def accept
        FORMATS['xml']
      end
      alias content_type accept
    end
  end
end

require 'recurly_v2/api/net_http_adapter'
