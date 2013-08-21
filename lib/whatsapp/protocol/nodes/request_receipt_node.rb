require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class RequestReceiptNode < Node

      def initialize
        super('request', {xmlns: 'urn:xmpp:receipts'})
      end

    end

  end
end
