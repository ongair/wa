require 'base64'
require 'pbkdf2'

include Socket::Constants

module Whatsapp
  module Api

    class Connection
      WHATSAPP_HOST         = 'c.whatsapp.net'
      WHATSAPP_SERVER       = 's.whatsapp.net'
      WHATSAPP_REALM        = 's.whatsapp.net'
      WHATSAPP_GROUP_SERVER = 'g.us'
      WHATSAPP_DIGEST       = 'xmpp/s.whatsapp.net'
      WHATSAPP_VERSION      = '2.8.7'
      DEVICE                = 'iPhone'
      PORT                  = 5222
      OPERATION_TIMEOUT     = 2
      CONNECT_TIMEOUT       = 5

      attr_reader :account_info

      attr_reader :reader, :challenge_data # For tests only!

      def initialize(number, imei, name)
        @login_status       = :disconnected
        @incomplete_message = new_binary_string
        @account_info       = nil

        @message_queue = []

        @socket = nil
        @writer = Whatsapp::Api::NodeWriter.new
        @reader = Whatsapp::Api::NodeReader.new

        @input_key  = nil
        @output_key = nil

        @number = number
        @imei   = imei
        @name   = name
      end

      def connect
        @socket = Whatsapp::Api::TCPSocket.new(WHATSAPP_HOST, PORT, OPERATION_TIMEOUT, CONNECT_TIMEOUT)
      end

      def poll_messages
        process_inbound_data(read_data)
      end

      def get_messages
        res = @message_queue

        @message_queue = []

        res
      end

      def typing_message(to)
        mama = to.index('-') ? WHATSAPP_GROUP_SERVER : WHATSAPP_SERVER

        send_node Whatsapp::Api::Node.new('message', {'to' => "#{to}@#{mama}", 'type' => 'chat'}, [
            Whatsapp::Api::Node.new('composing', {'xmlns' => 'http://jabber.org/protocol/chatstates'})
        ])
      end

      def read_data
        buffer = new_binary_string

        begin
          @socket.read(1024, buffer)
        rescue OperationTimeout
        end

        if buffer && buffer.length > 0
          buffer              = "#{@incomplete_message}#{buffer}"
          @incomplete_message = new_binary_string
        end

        buffer
      end

      def send_data(data)
        @socket.send(data)
      end

      def login
        resource = "#{DEVICE}-#{WHATSAPP_VERSION}-#{PORT}"
        data     = @writer.start_stream(WHATSAPP_SERVER, resource)

        feat = add_features
        auth = add_auth
        send_data(data)
        send_node(feat)
        send_node(auth)

        data = read_data
        process_inbound_data(data)
        data = add_auth_response
        send_node(data)
        @reader.key = @input_key
        @writer.key = @output_key

        cnt = 0
        process_inbound_data(read_data) while ((cnt += 1) < 100) && (@login_status == :disconnected)

        send_nickname
        send_presence
      end

      def send_nickname
        send_node Whatsapp::Api::Node.new('presence', {'name' => @name})
      end

      def send_presence(type = 'available')
        send_node Whatsapp::Api::Node.new('presence', {'type' => type, 'name' => @name})
      end

      def send_message_node(message_id, to, node)
        x_node = Whatsapp::Api::Node.new('x', {'xmlns' => 'jabber:x:event'}, [
            Whatsapp::Api::Node.new('server')
        ])

        mama = to.index('-') ? WHATSAPP_GROUP_SERVER : WHATSAPP_SERVER

        message_node = Whatsapp::Api::Node.new('message', {
            'to'   => "#{to}@#{mama}",
            'type' => 'chat',
            'id'   => message_id
        },                                     [x_node, node])

        send_node(message_node)
      end

      def message(message_id, to, body)
        send_message_node(message_id, to, Whatsapp::Api::Node.new('body', {}, [], body))
      end

      def close
        @socket.close if @socket
      end

      protected

      def add_features
        Whatsapp::Api::Node.new('stream:features', {}, [
            Whatsapp::Api::Node.new('receipt_acks')
        ])
      end

      def add_auth
        Whatsapp::Api::Node.new('auth', {
            'xmlns'     => 'urn:ietf:params:xml:ns:xmpp-sasl',
            'mechanism' => 'WAUTH-1',
            'user'      => @number
        })
      end

      def authenticate
        raw_password = Base64.decode64(@imei)

        key = PBKDF2.new(hash_function: :sha1, password: raw_password, salt: @challenge_data, iterations: 16, key_length: 20).bin_string

        @input_key  = Whatsapp::Api::KeyStream.new(key)
        @output_key = Whatsapp::Api::KeyStream.new(key)

        @output_key.encode("#{@number}#{@challenge_data}#{Time.now.to_i}", false)
      end

      def add_auth_response
        response = authenticate

        Whatsapp::Api::Node.new('response', {
            'xmlns' => 'urn:ietf:params:xml:ns:xmpp-sasl'
        },                      [], response)
      end

      def send_node(node)
        send_data(@writer.write(node))
      end

      def process_challenge(node)
        @challenge_data = node.data
      end

      def send_message_received(msg)
        if request_node = msg.child('request')
          xmlns = request_node.attribute('xmlns')

          if xmlns == 'urn:xmpp:receipts'
            received_node = Whatsapp::Api::Node.new('received', {'xmlns' => 'urn:xmpp:receipts'})
            message_node  = Whatsapp::Api::Node.new('message', {
                'to'   => msg.attribute('from'),
                'type' => 'chat',
                'id'   => msg.attribute('id')
            },                                      [received_node])

            send_node(message_node)
          end
        end
      end

      def process_inbound_data(data)
        node = @reader.next_tree(data)

        while node
          if node.tag == 'challenge'
            process_challenge(node)
          elsif node.tag == 'success'
            @login_status = :connected
            @account_info = {
                'status'     => node.attribute('status'),
                'kind'       => node.attribute('kind'),
                'creation'   => node.attribute('creation'),
                'expiration' => node.attribute('expiration')
            }
          end

          if node.tag == 'message'
            @message_queue << node
            send_message_received(node)
          end

          if node.tag == 'iq' && node.attribute('type') == 'get' && node.children && node.children.length > 0 && node.children[0].tag == 'ping'
            pong(node.attribute('id'))
          end

          if node.tag == 'iq' && node.attribute('type') == 'result' && node.children && node.children.length > 0 && node.children[0].tag == 'query'
            @message_queue << node
          end

          node = @reader.next_tree
        end
      rescue IncompleteMessageException => e
        @incomplete_message = e.input
      end
      
      private

      if defined?(Encoding)
        BINARY_ENCODING = Encoding.find('binary')

        def new_binary_string
          ''.force_encoding(BINARY_ENCODING)
        end
      else
        def new_binary_string
          ''
        end
      end

    end

  end
end
