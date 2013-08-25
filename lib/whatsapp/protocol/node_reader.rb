require 'yaml'

require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class NodeReader
      DICTIONARY_PATH = File.join(File.dirname(__FILE__), 'dictionary.yml')
      DICTIONARY      = YAML.load_file(DICTIONARY_PATH)

      BINARY_ENCODING = Encoding.find('BINARY')
      UTF8_ENCODING   = Encoding.find('UTF-8')

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
        @input = ''.force_encoding(BINARY_ENCODING)
      end

      def next_tree(input = nil)
        @input = input.force_encoding(BINARY_ENCODING) if input

        return if @input.nil? || @input.bytesize == 0

        read_more! if @input.bytesize < STANZA_HEADER_SIZE

        stanza_header    = peek_int8
        stanza_size      = peek_int16(1)
        stanza_header    = (stanza_header << 16) + stanza_size
        stanza_flags     = (stanza_header >> 20)
        stanza_encrypted = ((stanza_flags & 8) != 0)

        read_more! if @input.bytesize < STANZA_HEADER_SIZE + stanza_size

        read_int24

        if stanza_encrypted
          if @keystream
            remaining_data = @input.byteslice(stanza_size..-1)
            @input         = @keystream.decode(@input.byteslice(0, stanza_size)) << remaining_data
          else
            raise 'No key for encrypted data'
          end
        end

        stanza_size > 0 ? next_tree_internal : nil
      end

      protected

      def read_more!
        error       = IncompleteMessageException.new
        error.input = @input

        raise error
      end

      def get_token(token)
        if (token >= 0) && (token < DICTIONARY.size)
          DICTIONARY[token]
        else
          raise "No token #{token} in dictionary"
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
            raise 'Cannot create JID'
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
          return Node.new('start', read_attributes(size))
        elsif token == 2
          return nil
        end

        tag        = read_string(token)
        attributes = read_attributes(size)

        return Node.new(tag, attributes) if (size % 2) == 1

        token = read_int8

        if is_list_tag(token)
          Node.new(tag, attributes, read_list(token))
        else
          Node.new(tag, attributes, nil, read_string(token))
        end
      end

      def is_list_tag(token)
        (token == EMPTY_LIST) || (token == SHORT_LIST) || (token == LONG_LIST)
      end

      def read_list(list_type)
        size = read_list_size(list_type)

        res = []
        size.times { res << next_tree_internal }
        res
      end

      def read_list_size(list_type)
        if list_type == EMPTY_LIST
          0
        elsif list_type == SHORT_LIST
          read_int8
        elsif list_type == LONG_LIST
          read_int16
        else
          raise "Invalid list type #{list_type}"
        end
      end

      def peek_int24(offset = 0)
        raise("Cannot read 3 bytes from offset #{offset}") if @input.bytesize < 3 + offset

        (@input.getbyte(offset) << 16) | (@input.getbyte(offset + 1) << 8) | (@input.getbyte(offset + 2))
      end

      def read_int24
        res = peek_int24

        @input = @input.byteslice(3..-1)

        res
      end

      def peek_int16(offset = 0)
        raise("Cannot read 2 bytes from offset #{offset}") if @input.bytesize < 2 + offset

        (@input.getbyte(offset) << 8) | @input.getbyte(offset + 1)
      end

      def read_int16
        res = peek_int16

        @input = @input.byteslice(2..-1)

        res
      end

      def peek_int8(offset = 0)
        raise("Cannot read 1 byte from offset #{offset}") if @input.bytesize < 1 + offset

        @input.getbyte(offset)
      end

      def read_int8
        res = peek_int8

        @input = @input.byteslice(1..-1)

        res
      end

      def create_string(length)
        raise("Cannot read #{length} bytes from offset 0") if @input.bytesize < length

        res    = @input.byteslice(0, length)
        @input = @input.byteslice(length..-1)

        if res.force_encoding(UTF8_ENCODING).valid_encoding?
          res.encode!(UTF8_ENCODING)
        else
          res.force_encoding(BINARY_ENCODING)
        end
      end

    end

  end
end
