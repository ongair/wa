require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class IqNode < Node
      attr_reader :to, :message_id

      def initialize(query_nodes, message_id, to: nil, from: nil)
        @to         = to
        @message_id = message_id

        attributes = {
            id:   message_id,
            type: type
        }

        attributes[:to]   = to unless to.nil? || to.empty?
        attributes[:from] = from unless from.nil? || from.empty?

        super('iq', attributes, [*query_nodes])
      end

      private

      def type
        raise NotImplementedError
      end

    end

  end
end
