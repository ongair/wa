require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class PresenceNode < Node

      def initialize(name, type = nil)
        attributes = {name: name}

        attributes[:type] = type if type

        super('presence', attributes)
      end

    end

  end
end
