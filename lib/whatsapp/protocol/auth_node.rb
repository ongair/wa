require 'whatsapp/protocol/node'

module Whatsapp
  module Protocol

    class AuthNode < Node

      def initialize(number)
        super('auth', {
            xmlns:     'urn:ietf:params:xml:ns:xmpp-sasl',
            mechanism: 'WAUTH-1',
            user:      number
        })
      end

    end

  end
end
