require 'whatsapp/protocol/connection'
require 'whatsapp/protocol/composing_node'
require 'whatsapp/protocol/image_message_node'
require 'whatsapp/protocol/iq_media_node'
require 'whatsapp/protocol/paused_node'
require 'whatsapp/protocol/presence_node'
require 'whatsapp/protocol/profile_picture_node'
require 'whatsapp/protocol/status_message_node'

module WhatsApp

  class Client
    attr_reader :number, :name, :options

    def initialize(number, name = nil, options = {})
      @number     = number
      @name       = name
      @options    = options
      @connection = Protocol::Connection.new(number, name, options)
    end

    def connect
      @connection.connect
    end

    def close
      @connection.close
    end

    def auth(password)
      @connection.auth(password)
    end

    def poll_messages(until_empty = false)
      @connection.poll_messages(until_empty)
    end

    def get_messages
      @connection.get_messages
    end

    def send(message)
      mama = message.to.index('-') ? Protocol::Connection::WHATSAPP_GROUP_SERVER : Protocol::Connection::WHATSAPP_SERVER

      @connection.send_node(message.set_to("#{message.to}@#{mama}"))
    end

    def send_node(node)
      @connection.send_node(node)
    end

    def composing_message(to)
      mama = to.index('-') ? Protocol::Connection::WHATSAPP_GROUP_SERVER : Protocol::Connection::WHATSAPP_SERVER

      @connection.send_node(Protocol::ComposingNode.new("#{to}@#{mama}"))
    end

    def paused_message(to)
      mama = to.index('-') ? Protocol::Connection::WHATSAPP_GROUP_SERVER : Protocol::Connection::WHATSAPP_SERVER

      @connection.send_node(Protocol::PausedNode.new("#{to}@#{mama}"))
    end

    def send_name
      @connection.send_node(Protocol::PresenceNode.new(@name, nil))
    end

    def send_presence(type = 'available')
      @connection.send_node(Protocol::PresenceNode.new(@name, type))
    end

    def send_status_message(status_message = '')
      @connection.send_node(Protocol::StatusMessageNode.new(status_message))
    end

    def send_profile_picture(image_data, preview_data, to = number)
      mama = to.index('-') ? Protocol::Connection::WHATSAPP_GROUP_SERVER : Protocol::Connection::WHATSAPP_SERVER

      @connection.send_node(Protocol::ProfilePictureNode.new("#{to}@#{mama}", image_data, preview_data))
    end

    def account_info
      @connection.account_info
    end

    def input_keystream
      @connection.input_key
    end

    def output_keystream
      @connection.output_key
    end

  end

end
