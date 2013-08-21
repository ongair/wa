require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class ProfilePictureNode < Node

      def initialize(data)
        super('picture', {xmlns: 'w:profile:picture', type: 'image'}, nil, data)
      end

    end

  end
end
