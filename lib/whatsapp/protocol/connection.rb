require 'base64'
require 'pbkdf2'

require 'whatsapp/protocol/node_writer'
require 'whatsapp/protocol/node_reader'
require 'whatsapp/protocol/node'
require 'whatsapp/protocol/features_node'
require 'whatsapp/protocol/auth_node'
require 'whatsapp/protocol/auth_response_node'
require 'whatsapp/protocol/keystream'
require 'whatsapp/protocol/pong_node'
require 'whatsapp/net/tcp_socket'

module WhatsApp
  module Protocol

    class Connection
      WHATSAPP_HOST         = 'c.whatsapp.net'
      WHATSAPP_SERVER       = 's.whatsapp.net'
      WHATSAPP_REALM        = 's.whatsapp.net'
      WHATSAPP_GROUP_SERVER = 'g.us'
      WHATSAPP_DIGEST       = 'xmpp/s.whatsapp.net'
      WHATSAPP_VERSION      = '2.10.768'
      DEVICE                = 'Android'
      PORT                  = 5222
      OPERATION_TIMEOUT     = 2
      CONNECT_TIMEOUT       = 5

      BINARY_ENCODING = Encoding.find('binary')

      attr_reader :account_info, :session

      def initialize(number, name, passive: false, proxy: nil, debug_output: nil)
        reset

        @number = number
        @name   = name

        @passive      = passive
        @proxy        = proxy
        @debug_output = debug_output
      end

      def reset
        @login_status       = :disconnected
        @incomplete_message = ''.force_encoding(BINARY_ENCODING)
        @account_info       = nil

        @challenge      = nil
        @next_challenge = nil
        @authed_at      = nil
        @session        = nil

        @message_queue = []

        @socket = nil
        @writer = ::WhatsApp::Protocol::NodeWriter.new
        @reader = ::WhatsApp::Protocol::NodeReader.new

        @input_keystream  = nil
        @output_keystream = nil
      end

      def connect
        @socket = WhatsApp::Net::TCPSocket.new(WHATSAPP_HOST, PORT, OPERATION_TIMEOUT, CONNECT_TIMEOUT, @proxy)
      end

      def poll_messages(until_empty = false)
        begin
          process_inbound_data(read_data)
        end while until_empty && @incomplete_message.length > 0
      end

      def get_messages
        res = @message_queue

        @message_queue = []

        res
      end

      def read_data
        buffer = ''.force_encoding(BINARY_ENCODING)

        begin
          @socket.read(1024, buffer)
        rescue OperationTimeout
        end

        if buffer && buffer.length > 0
          buffer              = "#{@incomplete_message}#{buffer}"
          @incomplete_message = ''.force_encoding(BINARY_ENCODING)
        end

        buffer
      end

      def send_data(data)
        @socket.write(data)
      end

      def auth(password, challenge = nil)
        @challenge = nil
        session    = Session.new

        resource = "#{DEVICE}-#{WHATSAPP_VERSION}"
        data     = @writer.start_stream(WHATSAPP_SERVER, resource)

        send_data(data)
        send_node(FeaturesNode.new)

        if challenge
          session.type = :restored

          auth_data = setup_authentication(password, challenge)
          send_node(AuthNode.new(@number, auth_data, @passive))

          @reader.keystream = @input_keystream
        else
          send_node(AuthNode.new(@number, nil, @passive))
        end

        retries = 0
        poll_messages(:until_empty) while ((retries += 1) < 10) && (@login_status != :connected) && !@challenge

        if @login_status != :connected && @challenge
          session.type = :new

          auth_data = setup_authentication(password, @challenge)
          send_node(AuthResponseNode.new(auth_data))

          @reader.keystream = @input_keystream

          retries = 0
          poll_messages(:until_empty) while ((retries += 1) < 10) && (@login_status != :connected)

          @writer.keystream = @output_keystream
        end

        if @login_status == :connected
          session.next_challenge = @next_challenge
          session.authed_at      = @authed_at

          @next_challenge = nil
          @challenge      = nil
          @authed_at      = nil
        else
          session = nil
        end

        session
      end

      def close
        @socket.close if @socket

        reset
      end

      def send_node(node)
        debug("\e[30m<- #{node}\e[0m")

        send_data(@writer.write(node))
      end

      protected

      def setup_authentication(password, challenge)
        raw_password = Base64.decode64(password)

        key = PBKDF2.new(hash_function: :sha1, password: raw_password, salt: challenge, iterations: 16, key_length: 20).bin_string

        @input_keystream  = WhatsApp::Protocol::Keystream.new(key)
        @output_keystream = WhatsApp::Protocol::Keystream.new(key)

        @output_keystream.encode("#{@number}#{challenge}#{Time.now.to_i}", false)
      end

      def send_message_received(msg)
        if msg.attribute('type') == 'chat' && (request_node = msg.child('request'))
          if request_node.attribute('xmlns') == 'urn:xmpp:receipts'
            received_node = WhatsApp::Protocol::Node.new('received', {xmlns: 'urn:xmpp:receipts'})
            message_node  = WhatsApp::Protocol::Node.new('message', {
                to:   msg.attribute('from'),
                type: msg.attribute('type'),
                id:   msg.attribute('id')
            }, [received_node])

            send_node(message_node)
          end
        end
      end

      def process_inbound_data(data)
        node = @reader.next_tree(data)

        while node
          debug("\e[32m-> #{node}\e[0m")

          if node.tag == 'challenge'
            @challenge      = node.data
            @next_challenge = nil
          elsif node.tag == 'success'
            @login_status   = :connected
            @challenge      = nil
            @next_challenge = node.data
            @authed_at      = Time.at(node.attribute('t').to_i)

            @account_info   = {
                status:     node.attribute('status'),
                kind:       node.attribute('kind'),
                creation:   node.attribute('creation'),
                expiration: node.attribute('expiration')
            }
          end

          if node.tag == 'failure' && node.child('not-authorized')
            raise WhatsApp::AuthenticationError, 'Authentication failed'
          end

          if node.tag == 'message'
            @message_queue << node

            send_message_received(node)
          end

          if node.tag == 'iq' && node.attribute('type') == 'get' && node.children && node.children.length > 0 && node.children[0].tag == 'ping'
            send_node(Protocol::PongNode.new(node.attribute('id')))
          end

          if node.tag == 'iq' && node.attribute('type') == 'result' && node.children && node.children.length > 0 && ['query', 'duplicate', 'media'].include?(node.children[0].tag)
            @message_queue << node
          end

          node = @reader.next_tree
        end
      rescue IncompleteMessageException => e
        @incomplete_message = e.input
      end

      class Session < Struct.new(:type, :authed_at, :next_challenge)
      end

      private

      def debug(text)
        @debug_output.puts(text) if @debug_output
      end

    end

  end
end
