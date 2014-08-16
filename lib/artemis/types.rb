module Artemis

  module Types

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

    def read_uint
      read(4).unpack("L")[0]
    end

    def read_short
      read(2).unpack("s")[0]
    end

    def read_float
      f = read(4).unpack("f")[0]
    end

    def read_byte
      read(1).ord
    end

    def read_ascii_string
      read(read_int)
    end

    def read_string
      read(read_uint * 2).force_encoding("UTF-16LE").encode("UTF-8").gsub(/\u0000.*/, '')
    end

    def read_bit_field (length, h = nil)
      r = read(length).each_byte.map{|x|x.ord.to_s(2).rjust(8).reverse}.
          join.each_byte.map{|x|x==49}.reverse
      io = self
      r.singleton_class.__send__(:define_method, 'next') do |method, name = nil, &block|
        if pop
          begin
            v = io.__send__("read_#{method}")
            v = block.(v) if block
            h[name] = v if name
            v
          rescue => e
            puts "#{method}: #{name}: #{e.message}"
          end
        end 
      end
      r
    end

  end

end
