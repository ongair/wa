require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class PrivacyQueryNode < Node
      DEFAULT_LIST_NAMES = %w(default)

      def initialize(list_names = DEFAULT_LIST_NAMES)
        list_nodes = list_names.map do |list_name|
          Node.new('list', {name: list_name})
        end

        super('query', {xmlns: 'jabber:iq:privacy'}, list_nodes)
      end

    end

  end
end
