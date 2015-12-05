defmodule WebsocketWebsockets do

# TODO
def allowedOrigin do
  [ "sean.com",
    "localhost",
    "76.74.253.61.844"
  ]
end

# You give it a websockets handshake and it returns a proper response. Accepts a Fun as callback
# in order to parse things like cookies or protocol.
 
def handshake(bin) do
  handshake(bin,:false)
end
def handshake(bin,callback) do
    Lib.trace("Handshaking...")
    #Lib.trace(bin)
    httpRequest = bin
    fields = String.split(httpRequest, [" ", "\r\n"]) #<<0x0d0a::16>>])
    Lib.trace("Fields: #{fields}")
    %WebsocketWebsock{
               key: key,
               key1: _key1,
               key2: _key2,
               version: _version,
               protocol: _protocol,
               origin: origin,
               request: _request,
               host: _host,
               port: _port
            } = parseKeys(fields,%WebsocketWebsock{allowed: allowedOrigin, callback: callback})

    # TODO - filter unsupported protocols

    acceptKey = :base64.encode(:crypto.hash(:sha, <<"#{key}258EAFA5-E914-47DA-95CA-C5AB0DC85B11">>))

    ["HTTP/1.1 101 ", 
     #"WebSocket",
     "Switching Protocols\r\n",
     #"Protocol Handshake\r\n",
     "Upgrade: websocket\r\n",
     "Connection: Upgrade\r\n",
     "Sec-WebSocket-Origin: #{origin}\r\n",
     "Sec-WebSocket-Accept: #{acceptKey}\r\n",
     "\r\n"
    ]
end

def sendTcpMsg(clientS, msg) do
  Lib.trace("Sending", msg)
  encoded = encodeString(msg)
  Lib.trace("Sending encoded", encoded)
  :gen_tcp.send(clientS, encoded)
end

def encodeString(msg) do
  encodeStream(:binary.bin_to_list(msg))
end
def encodeStream(msg) do
  #masks = [:random.uniform(255), :random.uniform(255),
  #         :random.uniform(255), :random.uniform(255)]
  #[129, Enum.count(msg) ||| 128] ++ masks
  [130, Enum.count(msg)] ++ msg
end
#def encodeBytes([],encoded) do
#  encoded
#end
#def encodeBytes(msg,encoded) do
#  [byte|msg2]=msg
#  encodeBytes(msg2, masks2++[mask], encoded ++ [byte ^^^ mask])
#end

def alert(clientS,msg) do
  msg(clientS,"alert",msg)
end
def msg(clientS,msg) do
  Lib.trace("Sending msg '#{msg}'")
  #:gen_tcp.send(clientS,[0,msg,255])
  sendTcpMsg(clientS, msg)
end
def msg(clientS,type,msg) do
  Lib.trace("Sending msg '#{msg}' type '#{type}' to '#{:erlang.port_info(clientS)[:id]}'")
  #:gen_tcp.send(clientS,[0,type,<<" @@@ ">>,msg,255])
  sendTcpMsg(clientS, msg)
end

def die(clientS,msg) do
  Lib.trace("Websockets die '#{:erlang.port_info(clientS)[:id]}'")
  alert(clientS,msg)
  #:gen_tcp.send(clientS,[255,0])
  #:gen_tcp.send(clientS,[0,0,0,0,0,0,0,0,0])
  :gen_tcp.close(clientS)
  Lib.trace(MSG)
end

def parseKeys(["GET","/",request|t],websock) do
  #Lib.trace("ParseKeys Get: #{request}")
  #size = :binary.byte_size(request)-9
  #<<request1::size,_>> = request
  parseKeys(t,%{websock | request: request})
end

def parseKeys(["Host:",host|t],websock) do
  #Lib.trace("ParseKeys Host: #{host}")
  uri=URI.parse("ws://{host}")
  parseKeys(t,%{websock | host: uri.host, port: uri.port})
end

def parseKeys(["Upgrade:","websocket"|t],websock) do
  #Lib.trace("ParseKeys Upgrade: websocket")
  parseKeys(t,websock)
end

def parseKeys(["Sec-WebSocket-Protocol:",protocol|t],websock) do
  #Lib.trace("ParseKeys Sec-WebSocket-Protocol: #{protocol}")
  parseKeys(t,%{websock | protocol: protocol})
end

def parseKeys(["Sec-WebSocket-Key:",key|t],websock) do
  #Lib.trace("ParseKeys Sec-WebSocket-Key: #{key}")
  parseKeys(t,%{websock | key: key})
end

def parseKeys(["Sec-WebSocket-Version:",version|t],websock) do
  #Lib.trace("ParseKeys Sec-WebSocket-Version: #{version}")
  parseKeys(t,%{websock | version: version})
end

def parseKeys(["Origin:",origin|t],websock) do
  #Lib.trace("ParseKeys Origin: #{origin}")
  parseKeys(t,%{websock | origin: origin})
end
def parseKeys([], %WebsocketWebsock{origin: :undefined, host: :undefined} = _w) do
  #Lib.trace("ParseKeys Undefined")
  :nil
end
def parseKeys([], %WebsocketWebsock{} = w) do
  #Lib.trace("ParseKeys end")
  case  w.allowed do
    any ->
      test=:true
    allowed ->
      [_|Origin] = :re.replace(w.origin,"http://(www\.)?","",[:caseless])
      test = :lists.any(fn(Host) when 
        Host===Origin -> :true 
        (_) -> :false 
      end, allowed)
  end

  case test do
    :true -> w
    :false ->
      Lib.trace(w)
      throw("No matching allowed hosts")
  end
end

def parseKeys([],w) do
  #Lib.trace("ParseKeys [] #{w}")
  throw("Missing Information")
end

def parseKeys([ignore|t], %WebsocketWebsock{callback: :false} = w) do
  #Lib.trace("ParseKeys Ignoring [#{ignore}|t] callback=false")
  parseKeys(t,w)
end
def parseKeys([ignore|t], %WebsocketWebsock{} = w) do
  #Lib.trace("ParseKeys Ignoring [#{ignore}|t]")
  f=w.callback
  parseKeys(t, %{w | callbackData: f})
end

#def genKey(<<x::8,rest>>,numbers,spaces) when x>47 and x<58 do
#  genKey(rest,[x|numbers],spaces)
#end
#def genKey(<<>>,numbers,spaces) do
#  Lib.trace("Key: ",numbers)
#  :erlang.list_to_integer(:lists.reverse(numbers)) / spaces
#end
#def genKey(<<?\s::8,rest>>,numbers,spaces) do
#  genKey(rest,numbers,spaces+1)
#end
#def genKey(<<_::8,bin>>,numbers,spaces) do
#  genKey(bin,numbers,spaces)
#end

end
