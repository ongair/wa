require 'whatsapp/request/base'

module WhatsApp
  module Request
    class Sync

      class Auth < WhatsApp::Request::Base
        NC            = '00000001'
        REALM         = 's.whatsapp.net'
        QOP           = 'auth'
        DIGEST_URI    = 'WAWA/s.whatsapp.net'
        CHARSET       = 'utf-8'
        AUTH_METHOD   = 'X-WAWA'
        AUTH_TEMPLATE = %{%{auth_method}: username="%{username}",realm="%{realm}",nonce="%{nonce}",cnonce="%{cnonce}",nc="%{nc}",qop="auth",digest-uri="%{digest_uri}",response="%{response}",charset="utf-8"}

        def initialize(username, password, nonce = '0')
          super()

          self.url  = 'https://sro.whatsapp.net/v2/sync/a'
          self.type = :post

          cnonce      = (rand(900000000000000) + 100000000000000).to_s(36)
          credentials = "#{username}:s.whatsapp.net:#{Base64.decode64(password || '')}"

          response = encode(md5(encode(md5(md5(credentials) + ':' + nonce + ':' + cnonce)) +
                                    ':' + nonce + ':' + NC + ':' + cnonce + ':auth:' +
                                    encode(md5('AUTHENTICATE:' + DIGEST_URI))))

          auth_field = AUTH_TEMPLATE % {auth_method: AUTH_METHOD,
                                        username:    username,
                                        realm:       REALM,
                                        nonce:       nonce,
                                        cnonce:      cnonce,
                                        nc:          NC,
                                        digest_uri:  DIGEST_URI,
                                        response:    response}

          add_header('Authorization', auth_field)
        end

        private

        def md5(s)
          ::Digest::MD5.digest(s)
        end

        def encode(inp)
          def _enc(n)
            n < 10 ? n + 48 : n + 87
          end

          res = []

          inp.each_byte do |b|
            b += 256 if b < 0
            res << _enc(b >> 4) << _enc(b % 16)
          end

          res.pack('c*')
        end

      end

    end
  end
end