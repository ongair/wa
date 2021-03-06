require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class IqNode < Node
      attr_reader :to, :message_id

      def initialize(query_nodes, message_id, to: nil, from: nil, xmlns: nil)
        @to         = to
        @message_id = message_id.is_a?(Node) ? message_id.attribute('id') : message_id

        attributes = {
            id:   @message_id,
            type: type
        }

        attributes[:to]    = to unless to.nil? || to.empty?
        attributes[:from]  = from unless from.nil? || from.empty?
        attributes[:xmlns] = xmlns unless xmlns.nil? || xmlns.empty?

        super('iq', attributes, [*query_nodes])
      end

      private

      def type
        raise NotImplementedError
      end

    end

  end
end
