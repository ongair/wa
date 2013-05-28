require 'whatsapp/util/id_generator'
require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class ImageMessageNode < Node
      attr_reader :to, :body, :message_id

      def initialize(to, url, size, preview = nil, message_id = Util::IdGenerator.next)
        @to         = to
        @body       = body
        @message_id = message_id

        media_node = Node.new('media', {type: 'image', encoding: 'raw', size: size, xmlns: 'urn:xmpp:whatsapp:mms',
                                        url: url, file: File.basename(url)}, [], preview)

        receipts_node = Node.new('request', {xmlns: 'urn:xmpp:receipts'})

        x_node = Node.new('x', {xmlns: 'jabber:x:event'}, [
            Node.new('server')
        ])

        super('message', {
            to:   to,
            type: 'chat',
            id:   message_id
        },    [media_node, receipts_node, x_node])
      end

      def set_to(to)
        attributes[:to] = to

        self
      end

    end

  end
end
