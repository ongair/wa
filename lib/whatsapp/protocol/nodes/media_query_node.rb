require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class MediaQueryNode < Node

      def initialize(fingerprint, type, size)
        super('media', {
            xmlns: 'w:m',
            hash:  fingerprint,
            type:  type,
            size:  size
        })
      end

    end

  end
end
