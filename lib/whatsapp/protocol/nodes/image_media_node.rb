require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class ImageMediaNode < Node

      def initialize(url, size, preview = nil)
        attributes = {
            type:     'image',
            encoding: 'raw',
            size:     size,
            xmlns:    'urn:xmpp:whatsapp:mms',
            url:      url,
            file:     File.basename(url)
        }

        super('media', attributes, nil, preview)
      end

    end

  end
end
