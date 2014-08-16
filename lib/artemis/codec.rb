require 'forwardable'
require 'pp'

module Artemis

  class Codec
    extend Forwardable
    include Decoder
    include Encoder

    def_delegators :@io, :read, :eof?, :write, :close
    
    attr_accessor :role

    def initialize (io, role = 2)
      @io, @role = io, role
    end

    def write_packet (type, *args)
      data = __send__("pack_#{type}", *args)
      a = [0xdeadbeef, data.bytesize + 24, origin, 0, data.bytesize, data]
      @io.write(a.pack("LLLLLa*"))
    end

    def read_packet
      magic, _, origin, _, len, type = read(24).unpack("LLLLLL")
      data = read(len - 4)
      raise InvalidPacket unless magic == 0xdeadbeef
      [type, data]
    end

    def next
      until eof?
        type, data = read_packet
        catch :discard do
          begin
            return __send__("unpack_#{type.to_s(16)}", data)
          rescue => e
            puts ": #{e.message}"
          end
        end
      end
    end

  end

end
