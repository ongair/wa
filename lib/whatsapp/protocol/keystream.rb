require 'openssl'
require 'rc4'

module WhatsApp
  module Protocol

    class Keystream
      INIT = (0..255).map(&:chr).join

      def initialize(key)
        @key = key
        @rc4 = RC4.new(key)
        @rc4.encrypt(INIT)
      end

      def encode(data, append = true)
        data = @rc4.encrypt(data)
        hash = OpenSSL::HMAC.digest('sha1', @key, data)[0..3]

        append ? "#{data}#{hash}" : "#{hash}#{data}"
      end

      def decode(data)
        # TODO: Hash check
        @rc4.decrypt(data.byteslice(4..-1))
      end

    end

  end
end
