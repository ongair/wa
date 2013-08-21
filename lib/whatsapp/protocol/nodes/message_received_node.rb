require 'whatsapp/protocol/node'
require 'whatsapp/protocol/nodes/received_node'

module WhatsApp
  module Protocol

    class MessageReceivedNode < Node
      attr_reader :message, :timestamp

      def initialize(message, timestamp = Time.now.to_i)
        @message   = message
        @timestamp = timestamp

        super('message', {
            to:   message.attribute('from'),
            type: message.attribute('type'),
            id:   message.attribute('id'),
            t:    timestamp
        }, [WhatsApp::Protocol::ReceivedNode.new])
      end

    end

  end
end
