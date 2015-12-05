defmodule WorldServerListener do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(state) do
    Lib.trace("Starting WorldServerListener")
    :erlang.process_flag(:trap_exit, :true)
    port = 8083
    {:ok, sock} = :gen_tcp.listen(port, [:binary, {:packet, 0}, {:active, :true}, {:reuseaddr, :true}, {:packet_size,1024*2}, {:keepalive,:true}])
    Lib.trace("WorldServerListener Accepting connections on port #{port}")
    spawn(fn() -> accept_connections(sock) end)
    {:ok, sock}
  end

  def terminate(reason, sock) do
    :gen_tcp.close(sock)
  end

  #################################

  defmacro timeoutTime do
    30*1000
  end
  defmacro idleTime do
    60*10*1000
  end

  def accept_connections(sock) do
    Lib.trace("WorldServerListener Accepting connections")
    {:ok, client} = :gen_tcp.accept(sock)
    spawn(fn() -> accept_connections(sock) end)
    recv_connection(client)
  end

  def recv_connection(client) do
    Lib.trace("WorldServerListener waiting for data")
    receive do
      {_tcp,_,bin} ->
        Lib.trace("Recv from WorldServer:",bin)
        Lib.trace("type:", Packet.msgType(bin))
        msg = Packet.decode(bin)
        WebsocketUsers.notify(WebsocketUsers, bin)
        recv_connection(client)
      after timeoutTime ->
        Lib.trace("WorldServerListener timeout")
        :gen_tcp.close(client)
    end
  end

  #################################

end

