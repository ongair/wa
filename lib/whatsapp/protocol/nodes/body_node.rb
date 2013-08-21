require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class BodyNode < Node

      def initialize(body)
        super('body', nil, nil, body)
      end

    end

  end
end
