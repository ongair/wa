require 'whatsapp/request/base'

module WhatsApp
  module Request

    module Proxy
      attr_accessor :proxy

      def set_proxy(proxy)
        self.proxy = proxy

        self
      end
    end

  end
end
