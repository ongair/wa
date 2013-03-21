require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class FeaturesNode < Node

      def initialize
        super('stream:features', {}, [
            Node.new('receipt_acks'),
            Node.new('w:profile:picture', {type: 'all'}),
            Node.new('status')
        ])
      end

    end

  end
end
