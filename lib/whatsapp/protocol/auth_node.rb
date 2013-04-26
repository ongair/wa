require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class AuthNode < Node

      def initialize(number)
        super('auth', {
            user:      number,
            # passive:   'true', # It was in sniffed packets, but receipt akcs do not work when it's on
            xmlns:     'urn:ietf:params:xml:ns:xmpp-sasl',
            mechanism: 'WAUTH-1'
        })
      end

    end

  end
end
