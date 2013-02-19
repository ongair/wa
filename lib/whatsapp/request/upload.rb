require 'whatsapp/request/base'

module WhatsApp
  module Request

    class Upload < WhatsApp::Request::Base

      def initialize(file)
        super()

        self.type   = :post
        self.url    = 'https://mms.whatsapp.net/client/iphone/upload.php'
        self.params = {file: file}
      end

      def post
        self.response = HTTMultiParty.post(url, headers: headers, query: params)

        Plist::parse_xml(response.body)
      end

    end

  end
end
