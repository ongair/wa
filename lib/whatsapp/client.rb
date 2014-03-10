require 'whatsapp/protocol/connection'
require 'whatsapp/util/id_generator'

Dir[File.join(File.dirname(__FILE__), 'protocol', 'nodes', '*.rb')].each { |file| require(file) }

module WhatsApp

  class Client
    attr_reader :number, :nickname, :options

    def initialize(number, nickname = nil, options = {})
      @number     = number
      @nickname   = nickname
      @options    = options
      @connection = Protocol::Connection.new(number, options)
    end

    def connect
      @connection.connect
    end

    def close
      @connection.close
    end

    def auth(password, challenge = nil)
      @connection.auth(password, challenge)
    end

    def poll_messages
      @connection.poll_messages
    end

    def get_messages
      @connection.get_messages
    end

    def account_info
      @connection.account_info
    end

    def session
      @connection.session
    end

    def send_message(to, text)
      send_message_node(to, Protocol::BodyNode.new(text), :request_receipt, :notify_server, :request_server_receipt)
    end

    def send_image(to, url, size, preview = nil)
      send_message_node(to, Protocol::ImageMediaNode.new(url, size, preview), :request_receipt, :notify_server, :request_server_receipt)
    end

    def send_vcard(to, nickname, vcard)
      send_message_node(to, Protocol::VcardMediaNode.new(nickname, vcard), :request_receipt, :notify_server, :request_server_receipt)
    end

    def composing_message(to)
      send_message_node(to, Protocol::ComposingNode.new)
    end

    def paused_message(to)
      send_message_node(to, Protocol::PausedNode.new)
    end

    def set_status_message(status_message = '')
      send_message_node(Protocol::Connection::WHATSAPP_STATUS_SERVER, Protocol::BodyNode.new(status_message), :request_server_receipt)
    end

    def set_nickname(nickname)
      @nickname = nickname

      send_node(Protocol::PresenceNode.new(nickname))
    end

    def set_presence(type = 'available')
      send_node(Protocol::PresenceNode.new(nickname, type))
    end

    def set_online_presence
      set_presence('active')
    end

    def set_offline_presence
      set_presence('unavailable')
    end

    def set_profile_picture(image_data, preview_data, to: number)
      send_node(Protocol::SetIqNode.new([ProfilePictureNode.new(image_data), PicturePreviewNode.new(preview_data)], Util::IdGenerator.next, to: jid(to)))
    end

    def subscribe(to)
      send_node(Protocol::PresenceSubscriptionNode.new(jid(to)))
    end

    def query_last_seen(to)
      send_node(Protocol::GetIqNode.new(Protocol::LastSeenQueryNode.new, Util::IdGenerator.next, to: jid(to), from: jid(number)))
    end

    def query_media(fingerprint, type, size)
      send_node(Protocol::SetIqNode.new(Protocol::MediaQueryNode.new(fingerprint, type, size), Util::IdGenerator.next, to: Protocol::Connection::WHATSAPP_SERVER))
    end

    def query_privacy
      send_node(Protocol::GetIqNode.new(Protocol::PrivacyQueryNode.new, Util::IdGenerator.next))
    end

    def sync(numbers)
      send_node(Protocol::GetIqNode.new([Protocol::SyncNode.new(numbers)], Util::IdGenerator.next, to: jid(number), xmlns: 'urn:xmpp:whatsapp:sync'))
    end

    private

    def send_message_node(to, node, *features)
      send_node(Protocol::MessageNode.new(jid(to), message_feature_nodes(*features) << node, Util::IdGenerator.next))
    end

    def send_node(node)
      @connection.send_node(node)

      node
    end

    def message_feature_nodes(*features)
      feature_nodes = []

      feature_nodes << Protocol::RequestReceiptNode.new if features.delete(:request_receipt)
      feature_nodes << Protocol::NotifyServerNode.new(nickname) if features.delete(:notify_server)
      feature_nodes << Protocol::RequestServerReceiptNode.new if features.delete(:request_server_receipt)

      raise "No such feature#{'s' if features.length > 1}: #{features.join(', ')}" if features.any?

      feature_nodes
    end

    def jid(number)
      Protocol::Connection.jid(number)
    end

  end

end
