require 'whatsapp/protocol/node'
require 'whatsapp/protocol/nodes/user_node'

module WhatsApp
  module Protocol

    class SyncNode < Node
      attr_reader :numbers, :mode, :context, :index, :last

      def initialize(numbers, mode: 'full', context: 'registration', index: 0, last: true, sid: nil)
        @numbers = numbers
        @mode    = mode
        @context = context
        @index   = index
        @last    = last
        @sid     = sid || generate_sid

        super('sync', {
            mode:    @mode,
            context: @context,
            sid:     @sid,
            index:   @index.to_s,
            last:    !!@last
        }, UserNode.wrap(@numbers))
      end

      private

      def generate_sid
        #((Time.new.to_f + 11644477200) * 10000000).to_i.to_s
        ((Time.new.to_i + 11644477200) * 10000000).to_s
      end

    end

  end
end
