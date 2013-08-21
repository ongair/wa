require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class PicturePreviewNode < Node

      def initialize(data)
        super('picture', {type: 'preview'}, nil, data)
      end

    end

  end
end
