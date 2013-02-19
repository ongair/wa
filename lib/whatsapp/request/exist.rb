require 'whatsapp/request/base'

module WhatsApp
  module Request

    class Exist < WhatsApp::Request::Base

      def initialize(country_code, number, identity)
        super()

        self.url = 'https://v.whatsapp.net/v2/exist'

        self.params = {
            cc: country_code,
            in: number,
            id: identity
        }
      end

    end

  end
end
