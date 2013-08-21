require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class PausedNode < Node

      def initialize
        super('paused', {xmlns: 'http://jabber.org/protocol/chatstates'})
      end

    end

  end
end
