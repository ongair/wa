require 'whatsapp/request/base'

module WhatsApp
  module Request

    class Register < WhatsApp::Request::Base

      def initialize(country_code, number, code, identity)
        super()

        self.url = 'https://v.whatsapp.net/v2/register'

        self.params = {
            cc:   country_code,
            in:   number,
            id:   identity,
            code: code
        }
      end

    end

  end
end
