require 'whatsapp/protocol/node'

module Whatsapp
  module Protocol

    class AuthResponseNode < Node

      def initialize(auth_response)
        super('response', {xmlns: 'urn:ietf:params:xml:ns:xmpp-sasl'}, [], auth_response)
      end

    end

  end
end
