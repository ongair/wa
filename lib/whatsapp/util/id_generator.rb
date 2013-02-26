require 'singleton'

module Whatsapp
  module Util

    class IdGenerator
      include Singleton

      def initialize
        @id = 0
      end

      def self.next(prefix = '')
        instance.next(prefix)
      end

      def next(prefix = '')
        now = Time.new.to_f.to_s.split('.', 2)

        @id += 1

        "#{prefix}#{now[0]}#{now[1][0, 3]}#{100 + rand(900)}#{@id}"
      end
    end

  end
end
