require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class AuthNode < Node

      # Receipt akcs do not work when in passive mode, but there are a lot of server-delivery-timeouts when it's off
      def initialize(number, passive = false)
        attributes = {
            xmlns:     'urn:ietf:params:xml:ns:xmpp-sasl',
            mechanism: 'WAUTH-1',
            user:      number
        }

        attributes[:passive] = 'true' if passive

        super('auth', attributes)
      end

    end

  end
end
