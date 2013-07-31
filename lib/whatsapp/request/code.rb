require 'whatsapp/request/base'

module WhatsApp
  module Request

    class Code < WhatsApp::Request::Base
      IDENTITY = 'abcdef0123456789'

      def initialize(country_code, number, method = 'sms', options = {})
        super()

        self.url = 'https://v.whatsapp.net/v2/code'

        self.params = {
            cc:     country_code,
            in:     number,
            id:     IDENTITY,
            lg:     options[:language] || 'en',
            lc:     (options[:locale] || 'EN').to_s.upcase,
            mnc:    (options[:mnc] || '000').to_s.rjust(3, ?0),
            mcc:    (options[:mcc] || '000').to_s.rjust(3, ?0),
            method: method,
            reason: options[:reason] || '',
            token:  token(number.to_s)
        }
      end

    end

  end
end
