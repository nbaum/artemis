Thread.abort_on_exception = true

module Artemis

  class Proxy

    class Session

      def initialize (client)
        @client = Codec.new(client)
        @server = Codec.new(TCPSocket.new("192.168.1.10", 2011))
      end

      def run
        Thread.new do
          begin
            until @client.eof?
              type, data = @client.read_packet(false)
              catch :discard do
                p [">", @client.__send__("parse_#{type.to_s(16)}", data)]
                #p [type.to_s(16), data]
              end rescue nil
              @server.write_packet(type, data, 2)
            end
          rescue IOError, Errno::ECONNRESET
          ensure
            @server.close
          end
        end
        Thread.new do
          begin
            until @server.eof?
              type, data = @server.read_packet
              catch :discard do
                p ["<", @server.__send__("parse_#{type.to_s(16)}", data)]
              end rescue nil
              @client.write_packet(type, data, 1)
            end
          rescue IOError, Errno::ECONNRESET
          ensure
            @client.close
          end
        end
      end

    end

    def initialize ()
      @socket = TCPServer.new("127.0.0.1", 2010)
    end

    def run ()
      while true
        Session.new(@socket.accept).run
      end
    end

  end

end
