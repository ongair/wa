require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class AuthResponseNode < Node

      def initialize(auth_response)
        super('response', {xmlns: 'urn:ietf:params:xml:ns:xmpp-sasl'}, nil, auth_response)
      end

    end

  end
end
