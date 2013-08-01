require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class AuthNode < Node

      # Receipt akcs do not work when in passive mode, but there are a lot of server-delivery-timeouts when it's off
      def initialize(number, challenge = nil, passive = false)
        attributes = {
            passive:   !!passive,
            xmlns:     'urn:ietf:params:xml:ns:xmpp-sasl',
            mechanism: 'WAUTH-1',
            user:      number
        }

        super('auth', attributes, nil, challenge)
      end

    end

  end
end
