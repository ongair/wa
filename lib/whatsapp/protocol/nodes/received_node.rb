require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class ReceivedNode < Node

      def initialize
        super('received', {xmlns: 'urn:xmpp:receipts'})
      end

    end

  end
end
