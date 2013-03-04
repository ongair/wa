require 'socket'

module WhatsApp

  class IncompleteMessageException < IOError
    attr_accessor :input

  end

  class AuthenticationError < StandardError
  end

  class OperationTimeout < SocketError
  end

  class ProxyError < SocketError
  end

  class ConnectionFailure < RuntimeError
  end

end
