defmodule WebsocketEsWebsock do
use GenServer

# This code uses erlang OTP's gen_server to handle incoming data like messages and registration
# All data is centralized in the server state and is lost on exit. At this time there is no centralized database

def start_link(opts \\ []) do
  GenServer.start_link(__MODULE__, :ok, opts)
end

def init(:ok) do
  Lib.trace("Starting es websock...")
  :erlang.process_flag(:trap_exit, :true)
  #443
  port = 8081
  {:ok, s} = :gen_tcp.listen(port, [:binary, {:packet, 0}, {:active, :true}, {:reuseaddr, :true}, {:packet_size,1024*2},{:keepalive,:true}]) 
  Lib.trace("Accepting connections on port #{port}")
  spawn(fn() -> WebsocketConnect.accept_connections(s) end)
  {:ok, %WebsocketState{sock: s}}
end

def debug(server) do
  GenServer.call(server, :debug)
end

def stop(server) do
  GenServer.call(server, :die)
end

def gs(server) do
  GenServer.call(server, :getState)
end

def rs(server) do
  GenServer.call(server, :resetState)
end

def sendToAll(server, dict,you,message) do
  Lib.trace("SendToAll", dict)
  #TODO
  #:dict.map(dict,
  #  fn(id,_) 
  #  when id===you -> :nil
  #     (_,record) -> WebsocketWebsockets.sendTcpMsg(id.sock,[0,message,255])
  #  end)
end

def say(server, simple,message) do
  Lib.trace("eswebsock say")
  GenServer.cast(server, {:say,simple,message})
end

def move(server, simple,x,y) do
  GenServer.cast(server, {:move,simple,x,y})
end

def logout(server, simple) do
  GenServer.cast(server, {:logout,simple})
end

def checkUser(server, state) do
  Lib.trace("eswebsock checkUser")
  GenServer.call(server, {:checkUser,state})
end

################################
# GenServer Function Definitions

def handle_call({:checkUser,userState}, _, state) do
  Lib.trace("eswebsock handle call checkUser")
  WebsocketCheckUser.checkUser(userState,state)
end
def handle_call(:getState, _from, state) do
  {:reply,state,state}
end
def handle_call(:debug, _from, state) do
  %WebsocketState{ lookupByID: lbid, lookupByName: lbName, lookupByIP: lbip, maps: maps} = state
  Lib.trace(:dict.to_list(:array.get(0,maps)))
  Lib.trace(:gb_trees.to_list(lbName))
  Lib.trace(:gb_trees.to_list(lbip))
  Lib.trace(:dict.to_list(lbid))
  {:reply,:ok,state}
end
def handle_call(:resetState, _from, _state) do
  {:reply,:ok,%State{}}
end
def handle_call(:die, _from, state) do
  {:stop, :normal, state}
end
def handle_call(_request, _from, state) do
  Lib.trace("unknown gen_server:handle_call()",_request)
  {:reply, :ok, state}
end

def handle_cast({:say,simple,message}, state) when message !== ""  do
  WebsocketSay.say(simple,message,state)
end

def handle_cast({:move,simple,x,y}, state) do
  WebsocketMove.move(simple,x,y,state)
end

def handle_cast({:logout,simple}, state) do
  WebsocketLogout.logout(simple,state)
end

def handle_cast(_msg, state) do
  Lib.trace("gen_server:cast()",_msg)
  {:noreply, state}
end

def handle_info(_info, state) do
  Lib.trace("gen_server:handle_info()",_info)
  {:noreply, state}
end

def terminate(_reason, %WebsocketState{sock: sock} = state) do
  :gen_tcp.close(sock)
  Lib.trace("gen_server:terminate()",{_reason,state})
  :ok
end

def code_change(_oldVsn, state, _extra) do
  {:ok, state}
end

end
