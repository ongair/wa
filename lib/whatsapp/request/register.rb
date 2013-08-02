require 'whatsapp/request/base'

module WhatsApp
  module Request

    class Register < WhatsApp::Request::Base
      attr_reader :identity

      def initialize(country_code, number, code, device_id = nil)
        super()

        @identity = generate_identity(country_code, number, device_id)

        self.url = 'https://v.whatsapp.net/v2/register'

        self.params = {
            cc:   country_code,
            in:   number,
            id:   @identity,
            code: code
        }
      end

    end

  end
end
