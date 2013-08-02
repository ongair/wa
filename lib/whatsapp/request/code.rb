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
            lg:     (options[:language] || 'en').downcase,
            lc:     (options[:locale] || 'EN').upcase,
            mnc:    options[:mnc].to_s.rjust(3, ?0),
            mcc:    options[:mcc].to_s.rjust(3, ?0),
            method: method,
            reason: options[:reason] || '',
            token:  generate_token(number.to_s)
        }
      end

    end

  end
end
