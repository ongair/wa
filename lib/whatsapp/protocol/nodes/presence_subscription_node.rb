require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class PresenceSubscriptionNode < Node

      def initialize(to)
        super('presence', {
            type: 'subscribe',
            to:   to
        })
      end

    end

  end
end
