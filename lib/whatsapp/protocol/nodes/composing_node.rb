require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class ComposingNode < Node

      def initialize
        super('composing', {xmlns: 'http://jabber.org/protocol/chatstates'})
      end

    end

  end
end
