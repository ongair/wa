require 'whatsapp/protocol/node'
require 'whatsapp/protocol/nodes/vcard_node'

module WhatsApp
  module Protocol

    class VcardMediaNode < Node

      def initialize(name, vcard)
        super('media', {type: 'vcard', encoding: 'text', xmlns: 'urn:xmpp:whatsapp:mms'}, [VcardNode.new(name, vcard)])
      end

    end

  end
end
