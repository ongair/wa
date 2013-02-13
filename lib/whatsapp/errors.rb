require 'socket'

module Whatsapp

  class IncompleteMessageException < IOError
    attr_accessor :input

  end

  class OperationTimeout < SocketError
  end

  class ConnectionFailure < RuntimeError
  end

end
