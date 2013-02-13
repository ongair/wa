require 'whatsapp/protocol/node'

module Whatsapp
  module Protocol

    class ComposingNode < Node

      def initialize(to)
        super('message', {to: to, type: 'chat'}, [
            Node.new('composing', {xmlns: 'http://jabber.org/protocol/chatstates'})
        ])
      end

    end

  end
end
