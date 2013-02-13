require 'yaml'

module Whatsapp

  class NodeWriter
    DICTIONARY_PATH = File.join(File.dirname(__FILE__), 'dictionary.yml')
    DICTIONARY      = YAML.load_file(DICTIONARY_PATH)

    attr_accessor :key

    attr_reader :output

    def initialize
      @output = ''
    end

    def start_stream(domain, resource)
      attributes = {'to' => domain, 'resource' => resource}
      header     = "WA#{write_int8(1)}#{write_int8(2)}"
      write_list_start(attributes.size * 2 + 1)

      @output << "\x01"
      write_attributes(attributes)

      header + flush_buffer
    end

    def write(node)
      if node.nil?
        @output << "\x00"
      else
        write_internal(node)
      end

      flush_buffer
    end

    def write_internal(node)
      len = 1

      len += node.attributes.size * 2 if node.attributes
      len += 1 if node.children && node.children.size > 0
      len += 1 if node.data && node.data.size > 0

      write_list_start(len)
      write_string(node.tag)
      write_attributes(node.attributes)

      write_bytes(node.data) if node.data && node.data.size > 0
      if node.children && node.children.size > 0
        write_list_start(node.children.size)
        node.children.each { |child| write_internal(child) }
      end
    end

    def flush_buffer
      data    = key ? key.encode(@output) : @output
      size    = data.length
      @output = ''

      "#{write_int8(key ? (1 << 4) : 0)}#{write_int16(size)}#{data}"
    end

    def write_token(token)
      if token < 0xf5
        @output << token.chr
      elsif token <= 0x1f4
        @output << "\xfe" << (token - 0xf5).chr
      end
    end

    def write_jid(user, server)
      @output << "\xfa"

      if user && user.length > 0
        write_string(user)
      else
        write_token(0)
      end

      write_string(server)
    end

    def write_int8(value)
      (value & 0xff).chr
    end

    def write_int16(value)
      "#{((value & 0xff00) >> 8).chr}#{(value & 0x00ff).chr}"
    end

    def write_int24(value)
      "#{((value & 0xff0000) >> 16).chr}#{((value & 0x00ff00) >> 8).chr}#{(value & 0x0000ff).chr}"
    end

    def write_bytes(bytes)
      len = bytes.bytesize

      if len >= 0x100
        @output << "\xfd" << write_int24(len)
      else
        @output << "\xfc" << write_int8(len)
      end

      if bytes.is_a?(String)
        bytes.each_byte { |b| @output << b.chr }
      else
        @output << bytes
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
        @output << "\x00"
      elsif length < 0x100
        @output << "\xf8" << write_int8(length)
      else
        @output << "\xf9" << write_int16(length)
      end
    end

  end

end
