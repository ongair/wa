require 'whatsapp/protocol/node'

module Whatsapp
  module Protocol

    class FeaturesNode < Node

      def initialize
        super('stream:features', {}, [
            Node.new('receipt_acks')
        ])
      end

    end

  end
end
