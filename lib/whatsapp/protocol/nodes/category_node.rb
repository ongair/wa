require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class CategoryNode < Node

      def initialize(name)
        super('category', {name: name})
      end

    end

  end
end
