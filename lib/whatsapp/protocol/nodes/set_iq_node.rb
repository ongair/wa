require 'whatsapp/protocol/node'
require 'whatsapp/protocol/nodes/iq_node'

module WhatsApp
  module Protocol

    class SetIqNode < IqNode

      private

      def type
        'set'
      end

    end

  end
end
