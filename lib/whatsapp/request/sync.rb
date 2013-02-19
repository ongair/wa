require 'whatsapp/request/proxy'
require 'whatsapp/request/sync/auth'
require 'whatsapp/request/sync/query'

module WhatsApp
  module Request

    class Sync
      include WhatsApp::Request::Proxy

      def initialize(username, password, contacts)
        @username     = username
        @password     = password
        @contacts     = contacts
        @auth_request = Sync::Auth.new(username, password)
        @proxy        = nil
      end

      def perform
        auth = @auth_request.set_proxy(proxy).perform

        return auth unless auth['message'] == 'next token'

        authentication = @auth_request.response.headers['www-authenticate']
        nonce          = authentication.match(/nonce="([^"]+)/)[1]

        Sync::Query.new(@username, @password, nonce, @contacts).set_proxy(proxy).perform
      end
    end

  end
end