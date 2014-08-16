require 'artemis/decode'
require 'forwardable'
require 'pp'

module Artemis

  class Codec
    extend Forwardable
    include Decoder

    def_delegators :@io, :read, :eof?, :close

    def initialize (io)
      @io = io
    end

    def read_packet (verbose = false)
      header = read(24)
      magic, _, origin, _, len, type = header.unpack("LLLLLL")
      data = read(len - 4)
      if verbose
        STDOUT.write header + data
        STDOUT.flush
      end
      raise InvalidPacket unless magic == 0xdeadbeef
      [type, data]
    end

    def write_packet (type, data, origin)
      a = [0xdeadbeef, data.bytesize + 24, origin, 0, data.bytesize + 4, type, data]
      @io.write(a.pack("LLLLLLa*"))
    end

    def next
      until eof?
        type, data = read_packet
        catch :discard do
          return __send__("parse_#{type.to_s(16)}", data)
        end
      end
    end

  end

end
