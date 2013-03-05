require 'whatsapp/request/proxy'
require 'whatsapp/request/sync/auth'
require 'whatsapp/request/sync/query'

module WhatsApp
  module Request

    class Sync
      include WhatsApp::Request::Proxy

      attr_accessor :response

      def initialize(username, password, contacts)
        @username     = username
        @password     = password
        @contacts     = contacts
        @auth_request = Sync::Auth.new(username, password)
        @proxy        = nil
      end

      def perform
        auth          = @auth_request.set_proxy(proxy).perform
        self.response = @auth_request.response

        return auth unless auth['message'] == 'next token'

        authentication = @auth_request.response.headers['www-authenticate']
        nonce          = authentication.match(/nonce="([^"]+)/)[1]

        @query_request = Sync::Query.new(@username, @password, nonce, @contacts).set_proxy(proxy)
        query_response = @query_request.perform
        self.response  = @query_request.response

        query_response
      end
    end

  end
end