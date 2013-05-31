require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class IqMediaNode < Node

      def initialize(fingerprint, type, size, message_id = Util::IdGenerator.next)
        media_node = Node.new('media', {
            xmlns: 'w:m',
            hash:  fingerprint,
            type:  type,
            size:  size
        })

        super('iq', {
            id:   message_id,
            to:   's.whatsapp.net',
            type: 'set'
        }, [media_node])
      end

    end

  end
end
