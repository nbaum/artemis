require 'artemis/codec'
require 'artemis/client'
require 'artemis/proxy'
require 'socket'

Artemis::Proxy.new.run

#socket = TCPSocket.new("192.168.1.10", 2010)
#codec = Artemis::Codec.new(socket)
#client = Artemis::Client.new(codec)
#client.run
