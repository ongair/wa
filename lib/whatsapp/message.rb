require 'whatsapp/util/id_generator'
require 'whatsapp/protocol/node'

module WhatsApp

  class Message < Protocol::Node
    attr_reader :to, :body, :message_id

    def initialize(to, body, message_id = Util::IdGenerator.next)
      @to         = to
      @body       = body
      @message_id = message_id

      x_node = Protocol::Node.new('x', {xmlns: 'jabber:x:event'}, [
          Protocol::Node.new('server')
      ])

      body_node = Protocol::Node.new('body', {}, [], body)

      super('message', {
          to:   to,
          type: 'chat',
          id:   message_id
      }, [x_node, body_node])
    end

    def set_to(to)
      attributes[:to] = to

      self
    end

  end

end
