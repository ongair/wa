require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class PresenceNode < Node

      def initialize(name, type = 'available')
        attributes = type ? {type: type, name: name} : {name: name}

        super('presence', attributes)
      end

    end

  end
end