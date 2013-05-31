require 'httmultiparty'
require 'securerandom'

require 'whatsapp/request/base'

module WhatsApp
  module Request

    class Upload < WhatsApp::Request::Base

      def initialize(file, url)
        super()

        self.type   = :post
        self.url    = url
        self.params = {file: file}
      end

      def post
        self.response = HTTMultiParty.post(url, request_options(query: params))

        response.parsed_response
      end

    end

  end
end
