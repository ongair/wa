require 'whatsapp/request/base'

module WhatsApp
  module Request

    class Code < WhatsApp::Request::Base
      IDENTITY = 'abcdef0123456789'

      def initialize(country_code, number, method = 'sms', language = 'en', locale = 'EN', mnc = '000', mcc = '000', reason = '')
        super()

        self.url = 'https://v.whatsapp.net/v2/code'

        self.params = {
            cc:     country_code,
            in:     number,
            id:     IDENTITY,
            lg:     language,
            lc:     locale,
            mnc:    mnc,
            mcc:    mcc,
            method: method,
            reason: reason,
            token:  token(number.to_s)
        }
      end

    end

  end
end
