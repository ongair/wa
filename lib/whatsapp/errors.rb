require 'socket'

module WhatsApp

  class IncompleteMessageException < IOError
    attr_accessor :input

  end

  class AuthenticationError < Exception
  end

  class OperationTimeout < SocketError
  end

  class ProxyError < SocketError
  end

  class ConnectionFailure < RuntimeError
  end

end
