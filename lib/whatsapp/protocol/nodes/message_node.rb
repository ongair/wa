require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class MessageNode < Node
      attr_reader :to, :message_id, :timestamp

      def initialize(to, nodes, message_id, timestamp = Time.now.to_i)
        @to         = to
        @message_id = message_id
        @timestamp  = timestamp

        attributes = {
            to:   to,
            type: 'chat',
            id:   message_id,
            t:    timestamp
        }

        attributes[:t] = timestamp if timestamp

        super('message', attributes, [*nodes])
      end

    end

  end
end
