require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class ProfilePictureNode < Node
      attr_reader :to, :image_data, :message_id

      def initialize(to, image_data, preview_data, message_id = Util::IdGenerator.next)
        @to         = to
        @image_data = image_data
        @message_id = message_id

        picture_node = Node.new('picture', {xmlns: 'w:profile:picture', type: 'image'}, nil, image_data)
        preview_node = Node.new('picture', {type: 'preview'}, nil, preview_data)

        super('iq', {
            to:   to,
            type: 'set',
            id:   message_id
        }, [picture_node, preview_node])
      end

    end

  end
end
