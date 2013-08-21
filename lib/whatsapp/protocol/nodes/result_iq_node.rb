require 'whatsapp/protocol/node'
require 'whatsapp/protocol/nodes/iq_node'

module WhatsApp
  module Protocol

    class ResultIqNode < IqNode

      def initialize(message_id, to: nil, from: nil)
        super(message_id, to, from)
      end

      private

      def type
        'result'
      end

    end

  end
end
