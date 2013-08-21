require 'whatsapp/protocol/node'

module WhatsApp
  module Protocol

    class FeaturesNode < Node

      def initialize(*features)
        super('stream:features', nil, stream_feature_nodes(*features))
      end

      private

      def stream_feature_nodes(*features)
        feature_nodes = []

        feature_nodes << Node.new('receipt_acks') if features.delete(:receipts)
        feature_nodes << Node.new('w:profile:picture', {type: 'all'}) if features.delete(:profile_pictures)
        feature_nodes << Node.new('status', {notification: 'true'}) if features.delete(:status_notification)

        raise "No such feature#{'s' if features.length > 1}: #{features.join(', ')}" if features.any?

        feature_nodes
      end

    end

  end
end
