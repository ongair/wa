require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class PongNode < Node

      def initialize(message_id)
        super('iq', {to: 's.whatsapp.net', id: message_id, type: 'result'})
      end

    end

  end
end
