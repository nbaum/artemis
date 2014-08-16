module Artemis

  module ProtocolTypes

    def until_byte (byte, &block)
      until peekc == byte
        block.()
      end
      getc
    end

    def peekc
      c = getc
      ungetc(c)
      c.ord
    end

    def read_long
      read(8).unpack("q")[0]
    end

    def read_int
      read(4).unpack("l")[0]
    end

    def read_short
      read(2).unpack("s")[0]
    end

    def read_float
      f = read(4).unpack("f")[0]
      f = nil if f.nan?
      f
    end

    def read_byte
      read(1).ord
    end

    def read_ascii_string
      read(read_int)
    end

    def read_string
      read(read_int * 2).force_encoding("UTF-16LE").encode("UTF-8").gsub(/\u0000.*/, '')
    end

    def read_bit_field (length, h = nil)
      r = read(length).each_byte.map{|x|x.ord.to_s(2).rjust(8).reverse}.
          join.each_byte.map{|x|x==49}.reverse
      io = self
      r.singleton_class.__send__(:define_method, 'next') do |method, name = nil|
        if pop
          if name
            h[name] = io.__send__("read_#{method}")
          else
            v = io.__send__("read_#{method}")
            (h[:_] ||= []) << v
            v
          end
        end 
      end
      r
    end

  end

end
