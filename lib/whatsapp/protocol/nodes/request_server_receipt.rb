require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class RequestServerReceiptNode < Node

      def initialize
        super('x', {xmlns: 'jabber:x:event'}, [Node.new('server')])
      end

    end

  end
end
