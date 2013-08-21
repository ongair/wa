require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class VcardNode < Node

      def initialize(name, vcard)
        super('vcard', {name: name}, nil, vcard)
      end

    end

  end
end
