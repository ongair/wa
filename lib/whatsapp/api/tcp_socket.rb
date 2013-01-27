require 'socket'
require 'timeout'

# Code copied from "Ruby driver for MongoDB" project (https://github.com/mongodb/mongo-ruby-driver).
#
# Setting timeout using SO_RCVTIMEO socket option would not work, and using Ruby's Timeout.timeout is not recommended,
# the best option is to use IO.select.
#
# See http://stackoverflow.com/questions/9853516/set-socket-timeout-in-ruby-via-so-rcvtimeo-socket-option
module Whatsapp
  module Api

    # Wrapper class for Socket
    #
    # Emulates TCPSocket with operation and connection timeout
    # sans Timeout::timeout
    #
    class TCPSocket
      attr_accessor :pool, :pid

      def initialize(host, port, operation_timeout = nil, connect_timeout = nil)
        @op_timeout      = operation_timeout
        @connect_timeout = connect_timeout
        @pid             = Process.pid

        # TODO: Prefer ipv6 if server is ipv6 enabled
        @address         = Socket.getaddrinfo(host, nil, Socket::AF_INET).first[3]
        @port            = port

        @socket_address = Socket.pack_sockaddr_in(@port, @address)
        @socket         = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
        #@socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

        connect
      end

      def connect
        if @connect_timeout
          Timeout::timeout(@connect_timeout, OperationTimeout) do
            @socket.connect(@socket_address)
          end
        else
          @socket.connect(@socket_address)
        end
      end

      def send(data)
        @socket.write(data)
      end

      def read(maxlen, buffer)
        # Block on data to read for @op_timeout seconds
        begin
          ready = IO.select([@socket], nil, [@socket], @op_timeout)
          unless ready
            raise OperationTimeout
          end
        rescue IOError
          raise ConnectionFailure
        end

        # Read data from socket
        begin
          @socket.sysread(maxlen, buffer)
        rescue SystemCallError, IOError => ex
          raise ConnectionFailure, ex
        end
      end

      def close
        @socket.close
      end

      def closed?
        @socket.closed?
      end
    end

  end
end
