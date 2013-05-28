require 'httmultiparty'
require 'securerandom'

require 'whatsapp/request/base'

module WhatsApp
  module Request

    class Upload < WhatsApp::Request::Base

      def initialize(file)
        super()

        self.type   = :post
        self.url    = "https://mms836.whatsapp.net/u/#{SecureRandom.urlsafe_base64(28)}/#{SecureRandom.urlsafe_base64(33)}"
        self.params = {file: file}
      end

      def post
        self.response = HTTMultiParty.post(url, request_options(query: params))

        response.parsed_response
      end

    end

  end
end
