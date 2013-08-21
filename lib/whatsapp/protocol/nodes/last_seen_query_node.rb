require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class LastSeenQueryNode < Node

      def initialize
        super('query', {xmlns: 'jabber:iq:last'})
      end

    end

  end
end
