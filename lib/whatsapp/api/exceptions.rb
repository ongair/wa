require 'socket'
require 'base64'
require 'pbkdf2'
require 'timeout'

include Socket::Constants

module Whatsapp
  module Api

    class IncompleteMessageException < IOError
      attr_accessor :input

    end

    class OperationTimeout < SocketError
    end

    class ConnectionFailure < RuntimeError
    end

  end
end
