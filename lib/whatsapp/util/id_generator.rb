require 'singleton'

module WhatsApp
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
        #now = Time.new.to_f.to_s.split('.', 2)
        now = Time.new.to_i.to_s
        @id += 1

        #"#{prefix}#{now[0]}-#{@id}#{now[1][0, 3]}#{100 + rand(900)}"
        "#{prefix}#{now}-#{@id}"
      end
    end

  end
end
