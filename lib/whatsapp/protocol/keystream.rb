require 'openssl'
require 'rc4'

module WhatsApp
  module Protocol

    class Keystream
      @@seq = 0
      INIT = (0..255).map(&:chr).join

      def self.generate_keys(password, challenge)
        arr = [1, 2, 3, 4,]
        challenge += '0'
        ret = []
        arr.each_with_index do |v, i|
          challenge[-1] = v.chr
          ret << PBKDF2.new(hash_function: :sha1, password: password, salt: challenge, iterations: 2, key_length: 20).bin_string
        end
        ret
      end

      def initialize(key, mac_key)
        @key = key
        @mac_key = mac_key
        @rc4 = RC4.new(key)
        @rc4.encrypt(INIT)
        @rc4.encrypt(INIT)
        @rc4.encrypt(INIT)
      end

      def encode(buffer, mac_offset, offset, length)
        data = buffer.byteslice(0...offset) + @rc4.encrypt(buffer.byteslice(offset..-1))
        mac = compute_mac(data, offset, length)
        data.byteslice(0...mac_offset) + mac.byteslice(0...4) + data.byteslice(mac_offset+4..-1).to_s
      end

      def decode(data)
        # TODO: Hash check
        @rc4.decrypt(data.byteslice(4..-1) || '')
      end

      def compute_mac(data, offset, length)
        hmac = OpenSSL::HMAC.new(@mac_key, 'sha1')
        hmac.update(data.byteslice(offset...offset+length))
        arr = [(@@seq >> 24).chr, (@@seq >> 16).chr, (@@seq >> 8).chr, @@seq.chr]
        hmac.update(arr.join(''))
        @@seq += 1
        hmac.digest
      end

    end

  end
end
