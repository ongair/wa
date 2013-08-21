require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class AuthResponseNode < Node

      def initialize(auth_data)
        super('response', {xmlns: 'urn:ietf:params:xml:ns:xmpp-sasl'}, nil, auth_data)
      end

    end

  end
end
