require 'socket'
require 'timeout'

# Code copied from "Ruby driver for MongoDB" project (https://github.com/mongodb/mongo-ruby-driver/blob/master/lib/mongo/util/tcp_socket.rb).
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

        @address = ::TCPSocket.gethostbyname(host)[3]
        @port    = port

        connect
      end

      def connect
        if @connect_timeout
          Timeout::timeout(@connect_timeout, OperationTimeout) do
            @socket = ::TCPSocket.new(@address, @port)
          end
        else
          @socket = ::TCPSocket.new(@address, @port)
        end
      end

      def send(data)
        @socket.write(data)
      end

      def read(maxlen, buffer)
        # Block on data to read for @op_timeout seconds
        begin
          ready = IO.select([@socket], nil, [@socket], @op_timeout)

          raise OperationTimeout unless ready
        rescue IOError => ex
          raise ConnectionFailure, ex
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
