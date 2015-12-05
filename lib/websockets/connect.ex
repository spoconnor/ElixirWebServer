defmodule WebsocketConnect do
use Bitwise

defmacro timeoutTime do
  30*1000
end
defmacro idleTime do
 60*10*1000
end

def accept_connections(s) do
  Lib.trace("Accept_Connections")
  {:ok, clientS} = :gen_tcp.accept(s)
  spawn(fn() -> accept_connections(s) end)
  receive do
    {_tcp,_,bin} ->
      reply =  WebsocketWebsockets.handshake(bin)
      Lib.trace("Reply: #{reply} to '#{:erlang.port_info(clientS)[:id]}'")
      Lib.trace(:erlang.port_info(clientS))
      :gen_tcp.send(clientS, reply)
      #WebsocketWebsockets.sendTcpMsg(clientS, reply)
      step2(clientS)
    after timeoutTime ->
      WebsocketWebsockets.die(clientS, "Timeout on Handshake")
  end
end

def step2(clientS) do
  Lib.trace("Connection Step2")
  receive do
    {_tcp, _, bin1} ->
      Lib.trace("Received binary:", bin1)
      #str = to_string(decodeStream(bin1))
      str = decodeStream(bin1)
      Lib.trace("Received:", str)
      message = Packet.decode(str)
      Lib.trace("decoded")
      loginMsg(clientS, message)
    after timeoutTime ->
      WebsocketWebsockets.die(clientS,"Timeout on Handshake")
  end
end

# New User
def loginMsg(clientS, %CommsMessages.Message{msgtype: 4, from: _from, dest: _dest, newUser: newUser}) do
  Lib.trace("NewUser #{newUser.username} - TODO")
end

# Login
def loginMsg(clientS, %CommsMessages.Message{msgtype: 5, from: from, dest: _dest, login: login}) do
  Lib.trace("Login #{login.username} = #{from}")
  #if (length(user.name)>25) do
  #  WebsocketWebsockets.die("Name too long")
  #end
  {:ok,{ip,_}} = :inet.peername(clientS)
  state = %WebsocketUser{user: login.username, id: from, sock: clientS, x: 1,y: 1, ip: ip, pid: self()}

  notify_pid = spawn(fn() -> notify_thread(clientS) end)
  WebsocketUsers.add_user(WebsocketUsers, login.username, notify_pid)

  case WebsocketEsWebsock.checkUser(WebsocketWorker, state) do
    {:fail, _} -> WebsocketWebsockets.die(clientS,"Already Connected");
    id ->
      Lib.trace("ObjectId: #{id}")
      response = CommsMessages.Message.new(msgtype: 1, from: 1000, dest: id, response: CommsMessages.Response.new(code: 1, message: "Welcome #{login.username}!"))
      data = Packet.encode(response)
      WebsocketWebsockets.sendTcpMsg(clientS, data)
      client(%WebsocketSimple{id: id, sock: clientS})
  end
end

#def registerMsg(clientS, unexpected, _data) do
#  Lib.trace("Unexpected type received", unexpected)
#end

#def decodeString(data) do
#  decodeStream(:binary.bin_to_list(data))
#end
# binary encrypted string marker
def decodeStream(<<136::size(8),b2::size(8),t::binary>>) do
  <<mask1::size(8),mask2::size(8),mask3::size(8),mask4::size(8),data::binary>> = t
  masks = [mask1,mask2,mask3,mask4]
  #Lib.trace("DecodeMasks=#{mask1},#{mask2},#{mask3},#{mask4}")
  decodeBytes(data,masks,<<>>)
end
def decodeStream(<<130::size(8),b2::size(8),t::binary>>) do
  <<mask1::size(8),mask2::size(8),mask3::size(8),mask4::size(8),data::binary>> = t
  masks = [mask1,mask2,mask3,mask4]
  #Lib.trace("DecodeMasks=#{mask1},#{mask2},#{mask3},#{mask4}")
  decodeBytes(data,masks,<<>>)
end
# text encrypted string marker
def decodeStream(<<129::size(8),b2::size(8),t::binary>>) do
  #length = b2 &&& 127  # bitwise AND, unless special case
  #indexFirstMask = 2   # if not a special case
  # TODO - For message length > 126 bytes
  #if (length == 126)   # if a special case, change indexFirstMask
  #  indexFirstMask = 4
  #else if length == 127  # special case 2
  #  indexFirstMask = 10
  #end
  <<mask1::size(8),mask2::size(8),mask3::size(8),mask4::size(8),data::binary>> = t
  masks = [mask1,mask2,mask3,mask4]
  #Lib.trace("DecodeMasks=#{mask1},#{mask2},#{mask3},#{mask4}")
  decodeBytes(data,masks,<<>>)
end

def decodeBytes(<<>>,_masks,decoded) do
  decoded
end
def decodeBytes(data,masks,decoded) do
  <<byte::size(8),data2::binary>>=data
  [mask|masks2]=masks
  #Lib.trace("Decoding=#{byte} with mask #{mask} = #{byte ^^^ mask}")
  decodeBytes(data2, masks2++[mask], decoded <> <<byte ^^^ mask>>)
end

def client(state) do
  Lib.trace("Client #{state.id} receive loop")
  receive do
    {_tcp,_,bin} -> 
      Lib.trace("received bin:", bin)
      str = to_string(decodeStream(bin))
      Lib.trace("received:", str)
      Lib.trace("type:", Packet.msgType(str))

      # Send message thru Tcp connection to server

      {:ok, pid} = WorldServerClient.start_link({127,0,0,1}, 8842, [mode: :binary], 3000)
      WorldServerClient.send(pid, str)
      {:ok, resp} = WorldServerClient.recv(pid, 0)
      Lib.trace("WorldServer returned:", resp)
      Lib.trace("type:", Packet.msgType(resp))

      ## Send message thru rabbit queue
      #{:ok, conn} = AMQP.Connection.open("amqp://guest:guest@localhost")
      #{:ok, chan} = AMQP.Channel.open(conn)
      ##{:ok, _queue} = AMQP.Queue.declare( chan, Globals.send_queue, [auto_delete: true, durable: false, exclusive: false])
      ##:ok = AMQP.Exchange.declare(chan, Globals.mq_exchange, :direct, [auto_delete: true, durable: false])
      ##:ok = AMQP.Queue.bind chan, Globals.send_queue, Globals.mq_exchange
      #:ok = AMQP.Basic.publish(chan, Globals.mq_exchange, "Inbound", str)

      client(state)
    {:tcp_closed,_} ->
      logoutAndDie(state,"Disconnected")
    {:die,reason} ->
      logoutAndDie(state,reason)
    what ->
      Lib.trace(what)
      logoutAndDie(state,"Crash")
    after idleTime ->
      logoutAndDie(state,"Idle")
  end
end

def notify_thread(clientS) do
  Lib.trace("Client notify_thread")
  receive do
    data ->
      Lib.trace("Client notify thread recd", data)
      WebsocketWebsockets.sendTcpMsg(clientS, data)
      notify_thread(clientS)
  end
end

def logoutAndDie(state,msg) do
    WebsocketEsWebsock.logout(WebsocketWorker, state)
    WebsocketWebsockets.die(state.sock,msg)
end
    
end
