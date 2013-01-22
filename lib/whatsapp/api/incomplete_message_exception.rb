module Whatsapp
  module Api

    class IncompleteMessageException < IOError
      attr_accessor :input

    end

  end
end
