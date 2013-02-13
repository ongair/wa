require 'singleton'

module Whatsapp
  module Util

    class IdGenerator
      include Singleton

      def initialize
        @id = 0
      end

      def self.next
        instance.next
      end

      def next
        @id += 1

        "#{Time.new.to_i}-#{@id}"
      end
    end

  end
end
