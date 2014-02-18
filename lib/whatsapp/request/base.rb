require 'httparty'

require 'whatsapp/request/proxy'

module WhatsApp
  module Request

    class Base
      include WhatsApp::Request::Proxy

      DEVICES = {
          windows_phone: {
              user_agent: 'WhatsApp/2.8.2 WP7/7.10.8773.98 Device/NOKIA-Lumia_800-H112.1402.2.3',
              key:        'k7Iy3bWARdNeSL8gYgY6WveX12A1g4uTNXrRzt1H',
              token:      '889d4f44e479e6c38b4a834c6d8417815f999abe'
          },

          # Token is MD5 of classes.dex
          android:       {
              user_agent:   'WhatsApp/2.11.151 Android/4.3 Device/GalaxyS3',
              key:          '30820332308202f0a00302010202044c2536a4300b06072a8648ce3804030500307c310b3009060355040613025553311330110603550408130a43616c69666f726e6961311430120603550407130b53616e746120436c61726131163014060355040a130d576861747341707020496e632e31143012060355040b130b456e67696e656572696e67311430120603550403130b427269616e204163746f6e301e170d3130303632353233303731365a170d3434303231353233303731365a307c310b3009060355040613025553311330110603550408130a43616c69666f726e6961311430120603550407130b53616e746120436c61726131163014060355040a130d576861747341707020496e632e31143012060355040b130b456e67696e656572696e67311430120603550403130b427269616e204163746f6e308201b83082012c06072a8648ce3804013082011f02818100fd7f53811d75122952df4a9c2eece4e7f611b7523cef4400c31e3f80b6512669455d402251fb593d8d58fabfc5f5ba30f6cb9b556cd7813b801d346ff26660b76b9950a5a49f9fe8047b1022c24fbba9d7feb7c61bf83b57e7c6a8a6150f04fb83f6d3c51ec3023554135a169132f675f3ae2b61d72aeff22203199dd14801c70215009760508f15230bccb292b982a2eb840bf0581cf502818100f7e1a085d69b3ddecbbcab5c36b857b97994afbbfa3aea82f9574c0b3d0782675159578ebad4594fe67107108180b449167123e84c281613b7cf09328cc8a6e13c167a8b547c8d28e0a3ae1e2bb3a675916ea37f0bfa213562f1fb627a01243bcca4f1bea8519089a883dfe15ae59f06928b665e807b552564014c3bfecf492a0381850002818100d1198b4b81687bcf246d41a8a725f0a989a51bce326e84c828e1f556648bd71da487054d6de70fff4b49432b6862aa48fc2a93161b2c15a2ff5e671672dfb576e9d12aaff7369b9a99d04fb29d2bbbb2a503ee41b1ff37887064f41fe2805609063500a8e547349282d15981cdb58a08bede51dd7e9867295b3dfb45ffc6b259300b06072a8648ce3804030500032f00302c021400a602a7477acf841077237be090df436582ca2f0214350ce0268d07e71e55774ab4eacd4d071cd1efad',
              token:        '94bjoO7brhy/QJZRceJHYw==',
              identity_key: "S\x16\x0FR\x03\nD\x81\xD09\xF6\xD0\x80\xFE\xBB\x92\xA9\xCCF:!i)WA",
              signature:    'MIIDMjCCAvCgAwIBAgIETCU2pDALBgcqhkjOOAQDBQAwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFDASBgNVBAcTC1NhbnRhIENsYXJhMRYwFAYDVQQKEw1XaGF0c0FwcCBJbmMuMRQwEgYDVQQLEwtFbmdpbmVlcmluZzEUMBIGA1UEAxMLQnJpYW4gQWN0b24wHhcNMTAwNjI1MjMwNzE2WhcNNDQwMjE1MjMwNzE2WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEUMBIGA1UEBxMLU2FudGEgQ2xhcmExFjAUBgNVBAoTDVdoYXRzQXBwIEluYy4xFDASBgNVBAsTC0VuZ2luZWVyaW5nMRQwEgYDVQQDEwtCcmlhbiBBY3RvbjCCAbgwggEsBgcqhkjOOAQBMIIBHwKBgQD9f1OBHXUSKVLfSpwu7OTn9hG3UjzvRADDHj+AtlEmaUVdQCJR+1k9jVj6v8X1ujD2y5tVbNeBO4AdNG/yZmC3a5lQpaSfn+gEexAiwk+7qdf+t8Yb+DtX58aophUPBPuD9tPFHsMCNVQTWhaRMvZ1864rYdcq7/IiAxmd0UgBxwIVAJdgUI8VIwvMspK5gqLrhAvwWBz1AoGBAPfhoIXWmz3ey7yrXDa4V7l5lK+7+jrqgvlXTAs9B4JnUVlXjrrUWU/mcQcQgYC0SRZxI+hMKBYTt88JMozIpuE8FnqLVHyNKOCjrh4rs6Z1kW6jfwv6ITVi8ftiegEkO8yk8b6oUZCJqIPf4VrlnwaSi2ZegHtVJWQBTDv+z0kqA4GFAAKBgQDRGYtLgWh7zyRtQainJfCpiaUbzjJuhMgo4fVWZIvXHaSHBU1t5w//S0lDK2hiqkj8KpMWGywVov9eZxZy37V26dEqr/c2m5qZ0E+ynSu7sqUD7kGx/zeIcGT0H+KAVgkGNQCo5Uc0koLRWYHNtYoIvt5R3X6YZylbPftF/8ayWTALBgcqhkjOOAQDBQADLwAwLAIUAKYCp0d6z4QQdyN74JDfQ2WCyi8CFDUM4CaNB+ceVXdKtOrNTQcc0e+t',
              signature2:   '/UIGKU1FVQa+ATM2A0za7G2KI9S/CwPYjgAbc67v7ep42eO/WeTLx1lb1cHwxpsEgF4+PmYpLd2YpGUdX/A2JQitsHzDwgcdBpUf7psX1BU='
          },

          iphone:        {
              user_agent: 'WhatsApp/2.8.7 iPhone_OS/6.1 Device/iPhone_4',
              key:        '',
              token:      ''
          }
      }

      attr_accessor :device, :type, :url, :headers, :params, :response

      def initialize
        self.device   = :android
        self.type     = :get
        self.url      = ''
        self.headers  = {'User-Agent' => user_agent, 'Connection' => 'close'}
        self.params   = {}
        self.response = nil
        self.proxy    = nil
      end

      def user_agent
        DEVICES[device][:user_agent]
      end

      def add_header(name, value)
        headers[name] = value
      end

      def generate_token(number)
        signature2 = Base64.decode64(WhatsApp::Request::Base::DEVICES[:android][:signature2])
        data       = "#{Base64.decode64(DEVICES[device][:signature])}#{Base64.decode64(DEVICES[device][:token])}#{number}"

        opad = ''.force_encoding('BINARY')
        ipad = ''.force_encoding('BINARY')
        0.upto(63) do |index|
          opad << (0x5c ^ signature2.byteslice(index).ord)
          ipad << (0x36 ^ signature2.byteslice(index).ord)
        end

        output = Digest::SHA1.digest("#{opad}#{Digest::SHA1.digest("#{ipad}#{data}")}")

        Base64.strict_encode64(output)
      end

      # This is not the identity algorithm from official application, but it also generates 20-character string
      #
      # It will also auto-expire when protocol version is changed
      def generate_identity(country_code, number, device_id)
        key     = DEVICES[device][:identity_key]
        version = DEVICES[device][:user_agent]

        Digest::SHA1.digest("#{key}#{version}#{country_code}#{number}#{device_id}")
      end

      def perform
        type == :post ? post : get
      end

      def post
        add_header('Content-Type', 'application/x-www-form-urlencoded') unless headers['Content-Type']

        self.response = HTTParty.post(url, request_options(body: params))

        response.parsed_response
      end

      def get
        self.response = HTTParty.get(url, request_options(query: params))

        response.parsed_response
      end

      protected

      def request_options(options = {})
        options = options.merge(headers: headers)

        options.merge!(
            http_proxyaddr: proxy.host,
            http_proxyport: proxy.port,
            http_proxyuser: proxy.user,
            http_proxypass: proxy.password
        ) if proxy

        options
      end

    end

  end
end
