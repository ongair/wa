require 'whatsapp/request/base'

module WhatsApp
  module Request

    class Code < WhatsApp::Request::Base

      def initialize(country_code, number, identity, method = :sms)
        super()

        self.url = 'https://v.whatsapp.net/v2/code'

        self.params = {
            cc:     country_code,
            in:     number,
            lc:     'US',
            lg:     'en',
            mcc:    '000',
            mnc:    '000',
            method: method.to_s,
            id:     identity,
            token:  token(number.to_s)
        }
      end

    end

  end
end
