require 'socket'
require 'timeout'
require 'proxifier'
require 'whatsapp/errors'

# Code partially copied from "Ruby driver for MongoDB" project (https://github.com/mongodb/mongo-ruby-driver/blob/master/lib/mongo/util/tcp_socket.rb).
#
# Setting timeout using SO_RCVTIMEO socket option would not work, and using Ruby's Timeout.timeout is not recommended,
# the best option is to use IO.select.
#
# See http://stackoverflow.com/questions/9853516/set-socket-timeout-in-ruby-via-so-rcvtimeo-socket-option
module Whatsapp

  module Net

    # Wrapper class for TCPSocket
    #
    # Emulates TCPSocket with operation and connection timeout without using Timeout::timeout.
    # Proxy support added.
    #
    # Params:
    # +proxy+:: proxy server address as String in format +"protocol://[username[:password]@]host[:port]"+, eg.
    #           +"socks://joe:sekret@myproxy.net:60123"+
    class TCPSocket
      attr_accessor :pool, :pid

      def initialize(host, port, operation_timeout = nil, connect_timeout = nil, proxy = nil)
        @pid = Process.pid

        @operation_timeout = operation_timeout
        @connect_timeout   = connect_timeout
        @proxy             = proxy && Proxifier::Proxy(proxy)

        @address = ::TCPSocket.gethostbyname(host)[3]
        @port    = port

        connect
      end

      def write(data)
        @socket.write(data)
      end

      def read(maxlen, buffer)
        # Block on data to read for @op_timeout seconds
        begin
          ready = IO.select([@socket], nil, [@socket], @operation_timeout)

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

      private

      def connect
        if @connect_timeout
          Timeout::timeout(@connect_timeout, OperationTimeout) do
            open_socket
          end
        else
          open_socket
        end
      end

      def open_socket
        @socket = if @proxy
                    begin
                      @proxy.open(@address, @port)
                    rescue => e
                      proxy_error = Whatsapp::ProxyError.new(e.message)
                      proxy_error.set_backtrace(e.backtrace)

                      raise proxy_error
                    end
                  else
                    ::TCPSocket.new(@address, @port)
                  end
      end

    end

  end
end
