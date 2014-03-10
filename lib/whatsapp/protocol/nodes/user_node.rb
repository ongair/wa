require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class UserNode < Node

      def self.wrap(numbers)
        numbers.map { |number| UserNode.new(number) }
      end

      def initialize(number)
        super('user', nil, nil, number)
      end

    end

  end
end
