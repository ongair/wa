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

          android:       {
              user_agent: 'WhatsApp/2.9.1547 Android/4.2.1 Device/GalaxyS3',
              key:        '30820332308202f0a00302010202044c2536a4300b06072a8648ce3804030500307c310b3009060355040613025553311330110603550408130a43616c69666f726e6961311430120603550407130b53616e746120436c61726131163014060355040a130d576861747341707020496e632e31143012060355040b130b456e67696e656572696e67311430120603550403130b427269616e204163746f6e301e170d3130303632353233303731365a170d3434303231353233303731365a307c310b3009060355040613025553311330110603550408130a43616c69666f726e6961311430120603550407130b53616e746120436c61726131163014060355040a130d576861747341707020496e632e31143012060355040b130b456e67696e656572696e67311430120603550403130b427269616e204163746f6e308201b83082012c06072a8648ce3804013082011f02818100fd7f53811d75122952df4a9c2eece4e7f611b7523cef4400c31e3f80b6512669455d402251fb593d8d58fabfc5f5ba30f6cb9b556cd7813b801d346ff26660b76b9950a5a49f9fe8047b1022c24fbba9d7feb7c61bf83b57e7c6a8a6150f04fb83f6d3c51ec3023554135a169132f675f3ae2b61d72aeff22203199dd14801c70215009760508f15230bccb292b982a2eb840bf0581cf502818100f7e1a085d69b3ddecbbcab5c36b857b97994afbbfa3aea82f9574c0b3d0782675159578ebad4594fe67107108180b449167123e84c281613b7cf09328cc8a6e13c167a8b547c8d28e0a3ae1e2bb3a675916ea37f0bfa213562f1fb627a01243bcca4f1bea8519089a883dfe15ae59f06928b665e807b552564014c3bfecf492a0381850002818100d1198b4b81687bcf246d41a8a725f0a989a51bce326e84c828e1f556648bd71da487054d6de70fff4b49432b6862aa48fc2a93161b2c15a2ff5e671672dfb576e9d12aaff7369b9a99d04fb29d2bbbb2a503ee41b1ff37887064f41fe2805609063500a8e547349282d15981cdb58a08bede51dd7e9867295b3dfb45ffc6b259300b06072a8648ce3804030500032f00302c021400a602a7477acf841077237be090df436582ca2f0214350ce0268d07e71e55774ab4eacd4d071cd1efad',
              token:      '27c766c51b5f93b8f01e42d374cebd33'
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
        self.headers  = {'User-Agent' => user_agent}
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

      def token(number)
        key   = DEVICES[device][:key]
        token = DEVICES[device][:token]

        Digest::MD5.hexdigest("#{key}#{token}#{number}")
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
