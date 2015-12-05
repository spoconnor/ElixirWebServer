defmodule ParseTest do
  use ExUnit.Case

def allowedOrigin do
  [ "rp.eliteskills.com",
    "jimmyr.com",
    "localhost",
    "76.74.253.61.844"
  ]
end

  # A simple test
  test "Parse" do

    httpReq = <<"HttpRequest: GET / HTTP/1.1\r\nHost: localhost:8081\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: ouQOSesj+gPcmN8GoAvhNA==\r\nSec-WebSocket-Version: 13\r\nOrigin: http://faye.jcoglan.com\r\n\r\n">>

    fields = :binary.split(httpReq, <<0x0d0a::16>>, [:global])

    WebsocketWebsockets.parseKeys(fields, %WebsocketWebsock{allowed: allowedOrigin, callback: :false})

    IO.puts(fields)
    assert(1==1)
  end


end
