require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class CleanDirtyQueryNode < Node

      def initialize
        super('clean', {xmlns: 'urn:xmpp:whatsapp:dirty'})
      end

    end

  end
end
