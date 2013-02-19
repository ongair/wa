require 'whatsapp/request/base'

module WhatsApp
  module Request
    class Sync

      class Query < WhatsApp::Request::Sync::Auth

        def initialize(username, password, nonce, contacts)
          super(username, password, nonce)

          self.url = 'https://sro.whatsapp.net/v2/sync/q'

          self.params = {
              ut: 'all',
              t:  'c',
              u:  contacts
          }
        end

      end

    end
  end
end