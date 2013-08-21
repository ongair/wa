require 'whatsapp/protocol/node'
require 'whatsapp/protocol/nodes/iq_node'

module WhatsApp
  module Protocol

    class GetIqNode < IqNode

      private

      def type
        'get'
      end

    end

  end
end
