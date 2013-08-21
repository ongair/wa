require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class NotifyServerNode < Node

      def initialize(nickname = nil)
        attributes = {xmlns: 'urn:xmpp:whatsapp'}

        attributes[:name] = nickname if nickname && !nickname.empty?

        super('notify', attributes)
      end

    end

  end
end
