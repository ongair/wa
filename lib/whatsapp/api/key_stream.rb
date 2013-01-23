require 'openssl'
require 'rc4'

module Whatsapp
  module Api

    class KeyStream
      INIT = (0..255).map(&:chr).join

      def initialize(key)
        @key = key
        @rc4 = RC4.new(key)
        @rc4.encrypt(INIT)
      end

      def encode(data, append = true)
        d = @rc4.encrypt(data)
        h = OpenSSL::HMAC.digest('sha1', @key, d)[0..3]

        append ? "#{d}#{h}" : "#{h}#{d}"
      end

      def decode(data)
        # TODO: Hash check
        @rc4.decrypt(data[4..-1] || '')
      end

    end

  end
end
