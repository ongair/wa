require 'whatsapp/protocol/node'

module Whatsapp
  module Protocol

    class StatusMessageNode < Node
      attr_reader :status, :message_id

      def initialize(status = '', message_id = Util::IdGenerator.next)
        @status     = status
        @message_id = message_id

        x_node    = Node.new('x', {xmlns: 'jabber:x:event'}, [Node.new('server')])
        body_node = Node.new('body', {}, [], status)

        super('message', {
            to:   's.us',
            type: 'chat',
            id:   message_id
        }, [body_node, x_node])
      end

    end

  end
end
