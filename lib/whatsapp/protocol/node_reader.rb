require 'yaml'

require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class NodeReader
      DICTIONARY_PATH = File.join(File.dirname(__FILE__), 'dictionary.yml')
      DICTIONARY      = YAML.load_file(DICTIONARY_PATH)

      BINARY_ENCODING = Encoding.find('binary')

      attr_accessor :keystream, :input

      def initialize
        @input = ''.force_encoding(BINARY_ENCODING)
      end

      def next_tree(input = nil)
        @input = input.force_encoding(BINARY_ENCODING) if input

        stanza_flag = (peek_int8 & 0xf0) >> 4
        stanza_size = peek_int16(1)

        if @input && stanza_size > @input.bytesize - 2
          error       = IncompleteMessageException.new
          error.input = @input

          raise error
        end

        read_int24

        if (stanza_flag & 8) != 0
          if @keystream
            remaining_data = @input.byteslice(stanza_size..-1)
            @input         = "#{@keystream.decode(@input.byteslice(0, stanza_size))}#{remaining_data}".force_encoding(BINARY_ENCODING)
          else
            raise 'No key for encrypted data'
          end
        end

        stanza_size > 0 ? next_tree_internal : nil
      end

      protected

      def get_token(token)
        if (token >= 0) && (token < DICTIONARY.size)
          DICTIONARY[token]
        else
          raise "Invalid token #{token}"
        end
      end

      def read_string(token)
        res = nil

        raise "Invalid token #{token}" if token == -1

        if (token > 4) && (token < 0xf5)
          res = get_token(token)
        elsif token == 0xfc
          size = read_int8
          res  = fill_array(size)
        elsif token == 0xfd
          size = read_int24
          res  = fill_array(size)
        elsif token == 0xfe
          token = read_int8
          res   = get_token(token + 0xf5)
        elsif token == 0xfa
          user   = read_string(read_int8)
          server = read_string(read_int8)

          if user.length > 0 && server.length > 0
            res = "#{user}@#{server}"
          elsif server.length > 0
            res = server
          end
        end

        res
      end

      def read_attributes(size)
        attributes       = {}
        attributes_count = (size - 2 + size % 2) / 2

        attributes_count.times do
          key             = read_string(read_int8)
          value           = read_string(read_int8)
          attributes[key] = value
        end

        attributes
      end

      def next_tree_internal
        token = read_int8
        size  = read_list_size(token)
        token = read_int8

        if token == 1
          attributes = read_attributes(size)

          return Node.new('start', attributes)
        elsif token == 2
          return nil
        end

        tag        = read_string(token)
        attributes = read_attributes(size)

        return Node.new(tag, attributes) if (size % 2) == 1

        token = read_int8

        return Node.new(tag, attributes, read_list(token)) if is_list_tag(token)

        Node.new(tag, attributes, nil, read_string(token))
      end

      def is_list_tag(token)
        (token == 0) || (token == 0xf8) || (token == 0xf9)
      end

      def read_list(token)
        size = read_list_size(token)

        res = []
        size.times { res << next_tree_internal }
        res
      end

      def read_list_size(token)
        size = 0

        if token == 0xf8
          size = read_int8
        elsif token == 0xf9
          size = read_int16
        else
          raise "Invalid token #{token}"
        end

        size
      end

      def peek_int24(offset = 0)
        res = 0

        if @input && @input.bytesize >= 3 + offset
          res = @input.getbyte(offset) << 16
          res |= @input.getbyte(offset + 1) << 8
          res |= @input.getbyte(offset + 2) << 0
        end

        res
      end

      def read_int24
        res = peek_int24

        @input = @input.byteslice(3..-1) if res && @input && @input.bytesize >= 3

        res
      end

      def peek_int16(offset = 0)
        res = 0

        if @input && @input.bytesize >= 2 + offset
          res = @input.getbyte(offset) << 8
          res |= @input.getbyte(offset + 1) << 0
        end

        res
      end

      def read_int16
        res = peek_int16

        @input = @input.byteslice(2..-1) if res && @input && @input.bytesize >= 2

        res
      end

      def peek_int8(offset = 0)
        @input && @input.bytesize >= 1 + offset ? @input.getbyte(offset) : 0
      end

      def read_int8
        res = peek_int8

        @input = @input.byteslice(1..-1) if res && @input && @input.bytesize >= 1

        res
      end

      def fill_array(len)
        res = ''.force_encoding(BINARY_ENCODING)

        if @input && @input.bytesize >= len
          res    = @input.byteslice(0, len)
          @input = @input.byteslice(len..-1)
        end

        res
      end

    end

  end
end
