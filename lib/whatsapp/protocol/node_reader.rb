require 'yaml'

require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class NodeReader
      #DICTIONARY_PATH = File.join(File.dirname(__FILE__), 'dictionary.yml')
      #DICTIONARY      = YAML.load_file(DICTIONARY_PATH)

      BINARY_ENCODING = Encoding.find('binary')

      STANZA_HEADER_SIZE = 0x03
      EMPTY_LIST         = 0x00
      SHORT_LIST         = 0xf8
      LONG_LIST          = 0xf9
      JID_PAIR           = 0xfa
      SHORT_STRING       = 0xfc
      LONG_STRING        = 0xfd
      LONG_TOKEN         = 0xfe

      attr_accessor :keystream, :input

      def initialize
        @input     = ''.force_encoding(BINARY_ENCODING)
        @old_input = @input.dup.freeze
      end

      def next_tree(input = nil)
        @input     = input.force_encoding(BINARY_ENCODING) if input
        @old_input = @input.dup.freeze

        return if @input.nil? || @input.bytesize == 0

        read_more! if @input.bytesize < STANZA_HEADER_SIZE

        stanza_flag = (peek_int8 & 0xf0) >> 4
        stanza_size = peek_int16(1)

        read_more! if @input.bytesize < stanza_size

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

      def read_more!
        error       = IncompleteMessageException.new
        error.input = @old_input.dup

        raise error
      end

      def get_token(token)
        if (token >= 0) && (token < DICTIONARY.size)
          DICTIONARY[token]
        else
          raise "Invalid token #{token}"
        end
      end

      def read_string(token)
        if token == 0x00
          nil
        elsif token > 0x04 && token < 0xf5
          get_token(token)
        elsif token == SHORT_STRING
          create_string(read_int8)
        elsif token == LONG_STRING
          create_string(read_int24)
        elsif token == LONG_TOKEN
          token = read_int8
          get_token(token + 0xf5)
        elsif token == JID_PAIR
          user   = read_string(read_int8)
          server = read_string(read_int8)

          if user.length > 0 && server.length > 0
            "#{user}@#{server}"
          elsif server.length > 0
            server
          else
            raise "Cannot create JID"
          end
        else
          raise "Invalid token #{token}"
        end
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
        (token == EMPTY_LIST) || (token == SHORT_LIST) || (token == LONG_LIST)
      end

      def read_list(token)
        size = read_list_size(token)

        res = []
        size.times { res << next_tree_internal }
        res
      end

      def read_list_size(token)
        if token == EMPTY_LIST
          0
        elsif token == SHORT_LIST
          read_int8
        elsif token == LONG_LIST
          read_int16
        else
          raise "Invalid token #{token}"
        end
      end

      def peek_int24(offset = 0)
        res = nil

        if @input.bytesize >= 3 + offset
          res = @input.getbyte(offset) << 16
          res |= @input.getbyte(offset + 1) << 8
          res |= @input.getbyte(offset + 2) << 0
        end

        res || read_more!
      end

      def read_int24
        res = peek_int24

        @input = @input.byteslice(3..-1) if res && @input && @input.bytesize >= 3

        res
      end

      def peek_int16(offset = 0)
        res = nil

        if @input.bytesize >= 2 + offset
          res = @input.getbyte(offset) << 8
          res |= @input.getbyte(offset + 1) << 0
        end

        res || read_more!
      end

      def read_int16
        res = peek_int16

        @input = @input.byteslice(2..-1) if res && @input && @input.bytesize >= 2

        res
      end

      def peek_int8(offset = 0)
        @input.bytesize >= 1 + offset ? @input.getbyte(offset) : read_more!
      end

      def read_int8
        res = peek_int8

        @input = @input.byteslice(1..-1) if res && @input && @input.bytesize >= 1

        res
      end

      def create_string(length)
        res = ''.force_encoding(BINARY_ENCODING)

        if @input.bytesize >= length
          res    = @input.byteslice(0, length)
          @input = @input.byteslice(length..-1)
        end

        res
      end

    end

  end
end
