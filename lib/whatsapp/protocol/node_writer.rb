require 'yaml'

module WhatsApp
  module Protocol

    class NodeWriter
      DICTIONARY_PATH = File.join(File.dirname(__FILE__), 'dictionary.yml')
      DICTIONARY      = YAML.load_file(DICTIONARY_PATH)

      BINARY_ENCODING = Encoding.find('binary')
      HEADER          = "WA\x01\x02".force_encoding(BINARY_ENCODING)

      attr_accessor :keystream

      attr_reader :output

      def initialize
        @output = ''.force_encoding(BINARY_ENCODING)
      end

      def start_stream(domain, resource)
        attributes = {to: domain, resource: resource}

        write_list_start(attributes.size * 2 + 1)
        write_int8(0x01)
        write_attributes(attributes)

        HEADER + flush_buffer
      end

      def write(node)
        if node
          write_internal(node)
        else
          write_int8(0x00)
        end

        flush_buffer
      end

      private

      def flush_buffer
        data = keystream ? keystream.encode(@output, @output.length, 0, @output.length) : @output

        stanza_header(data.length, !!keystream) << data
      ensure
        @output.clear
      end

      def stanza_header(size, encrypted)
        stanza_flags = ((size & 0x0f0000) >> 16)
        stanza_flags |= (1 << 4) if encrypted

        ''.force_encoding(BINARY_ENCODING) << stanza_flags << ((size & 0xff00) >> 8) << (size & 0xff)
      end

      def write_internal(node)
        length = 1

        length += node.attributes.size * 2 if node.attributes
        length += 1 if node.children && node.children.size > 0
        length += 1 if node.data && node.data.size > 0

        write_list_start(length)
        write_string(node.tag)
        write_attributes(node.attributes)
        write_bytes(node.data) if node.data && node.data.size > 0

        if node.children && node.children.size > 0
          write_list_start(node.children.size)
          node.children.each { |child| write_internal(child) }
        end
      end

      def write_token(token)
        if token < 0xf5
          write_int8(token)
        elsif token <= 0x1f4
          write_int8(0xfe)
          write_int8(token - 0xf5)
        end
      end

      def write_jid(user, server)
        write_int8(0xfa)

        if user && user.length > 0
          write_string(user)
        else
          write_token(0x00)
        end

        write_string(server)
      end

      def write_int8(value)
        @output << (value & 0xff)
      end

      def write_int16(value)
        @output << ((value & 0xff00) >> 8) << (value & 0x00ff)
      end

      def write_int24(value)
        @output << ((value & 0xff0000) >> 16) << ((value & 0x00ff00) >> 8) << (value & 0x0000ff)
      end

      def write_bytes(bytes)
        length = bytes.bytesize

        if length <= 0xff
          write_int8(0xfc)
          write_int8(length)
        else
          write_int8(0xfd)
          write_int24(length)
        end

        if bytes.is_a?(String)
          bytes.each_byte { |byte| write_int8(byte) }
        elsif bytes.is_a?(Array)
          bytes.each { |byte| write_int8(byte) }
        end
      end

      def write_string(tag)
        if index = DICTIONARY.index(tag)
          write_token(index)
        else
          if tag.index('@')
            user, _, server = tag.partition('@')
            write_jid(user, server)
          else
            write_bytes(tag)
          end
        end
      end

      def write_attributes(attributes)
        if attributes
          attributes.each do |key, value|
            write_string(key.to_s)
            write_string(value.to_s)
          end
        end
      end

      def write_list_start(length)
        if length == 0
          write_int8(0)
        elsif length <= 0xff
          write_int8(0xf8)
          write_int8(length)
        else
          write_int8(0xf9)
          write_int16(length)
        end
      end

    end

  end
end
