require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class PausedNode < Node

      def initialize(to)
        super('message', {to: to, type: 'chat'}, [
            Node.new('paused', {xmlns: 'http://jabber.org/protocol/chatstates'})
        ])
      end

    end

  end
end
