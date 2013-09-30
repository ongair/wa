require 'base64'
require 'pbkdf2'

require 'whatsapp/net/tcp_socket'
require 'whatsapp/protocol/keystream'
require 'whatsapp/protocol/node_writer'
require 'whatsapp/protocol/node_reader'
require 'whatsapp/protocol/nodes/auth_node'
require 'whatsapp/protocol/nodes/auth_response_node'
require 'whatsapp/protocol/nodes/features_node'
require 'whatsapp/protocol/nodes/message_received_node'
require 'whatsapp/protocol/nodes/result_iq_node'
require 'whatsapp/util/id_generator'

module WhatsApp
  module Protocol

    class Connection
      WHATSAPP_HOST          = 'c.whatsapp.net'
      WHATSAPP_SERVER        = 's.whatsapp.net'
      WHATSAPP_REALM         = 's.whatsapp.net'
      WHATSAPP_GROUP_SERVER  = 'g.us'
      WHATSAPP_STATUS_SERVER = 's.us'
      WHATSAPP_DIGEST        = 'xmpp/s.whatsapp.net'
      WHATSAPP_VERSION       = '2.11.69'
      DEVICE                 = 'Android'
      PORT                   = 5222
      OPERATION_TIMEOUT      = 2
      CONNECT_TIMEOUT        = 5
      BUFFER_SIZE            = 1024

      BINARY_ENCODING = Encoding.find('binary')

      attr_reader :account_info, :session

      def self.jid(number)
        if number.index('@') || number.index('.')
          number
        else
          server = number.index('-') ? WHATSAPP_GROUP_SERVER : WHATSAPP_SERVER

          "#{number}@#{server}"
        end
      end

      def initialize(number, passive: false, proxy: nil, debug_output: nil, debug_id: nil)
        reset

        @number       = number
        @passive      = passive
        @proxy        = proxy
        @debug_output = debug_output
        @debug_id     = debug_id
      end

      def reset
        @login_status = :disconnected
        @buffer       = ''.force_encoding(BINARY_ENCODING)
        @read_more    = false
        @account_info = nil

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

      def poll_messages(*args)
        begin
          process_inbound_data(read_data)
        end while @read_more || @buffer.bytesize > 0
      end

      def get_messages
        res = @message_queue

        @message_queue = []

        res
      end

      def read_data
        @read_more = false
        chunk      = ''.force_encoding(BINARY_ENCODING)

        begin
          @socket.read(BUFFER_SIZE, chunk)
        rescue OperationTimeout
        end

        if chunk.bytesize > 0
          @read_more = chunk.bytesize == BUFFER_SIZE
          chunk      = @buffer << chunk
          @buffer    = ''.force_encoding(BINARY_ENCODING)
        end

        chunk
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
        send_node(FeaturesNode.new(:receipts, :profile_pictures, :status_notification))

        if challenge
          session.type = :restored

          auth_data = setup_authentication(password, challenge)
          send_node(AuthNode.new(@number, auth_data, @passive))

          @reader.keystream = @input_keystream
        else
          send_node(AuthNode.new(@number, nil, @passive))
        end

        retries = 0
        poll_messages while ((retries += 1) < 10) && (@login_status != :connected) && !@challenge

        if @login_status != :connected && @challenge
          session.type = :new

          auth_data = setup_authentication(password, @challenge)
          send_node(AuthResponseNode.new(auth_data))

          @reader.keystream = @input_keystream

          retries = 0
          poll_messages while ((retries += 1) < 10) && (@login_status != :connected)
        end

        if @login_status == :connected
          @writer.keystream = @output_keystream

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
        debug("<- #{node}", 34)

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

      def send_receipt(message)
        if (request_node = message.child('request') || message.child('received')) && (request_node.attribute('xmlns') == 'urn:xmpp:receipts')
          send_node(MessageReceivedNode.new(message))
        end
      end

      def process_inbound_data(data)
        node = @reader.next_tree(data)

        while node
          debug("-> #{node}", 32)

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

            send_receipt(node)
          end

          if node.tag == 'iq' && node.attribute('type') == 'get' && node.children && node.children.length > 0 && node.children[0].tag == 'ping'
            send_node(ResultIqNode.new(node.attribute('id'), to: WHATSAPP_SERVER))
          end

          if node.tag == 'iq' && node.attribute('type') == 'result' && node.children && node.children.length > 0 && ['query', 'duplicate', 'media'].include?(node.children[0].tag)
            @message_queue << node
          end

          if node.tag == 'presence' && node.attribute('status') == 'dirty'
            send_node(SetIqNode.new(CleanDirtyQueryNode.new(node), Util::IdGenerator.next, to: WHATSAPP_SERVER))
          end

          node = @reader.next_tree
        end
      rescue IncompleteMessageException => error
        @buffer = error.input
      end

      class Session < Struct.new(:type, :authed_at, :next_challenge)
      end

      private

      def debug(text, color = nil)
        return unless @debug_output

        text = "[#{@debug_id}] #{text}" if @debug_id
        text = "\e[#{color}m#{text}\e[0m" if color

        @debug_output.puts(text)
      end

    end

  end
end
