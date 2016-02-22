defmodule World.Server do
use GenServer

#-------------------------------------------------------------------
# API Function Definitions

# spawn and links to new process in one atomic step
def start_link(opts \\ []) do
  GenServer.start_link( __MODULE__, :ok, opts)
end

# Use cast to send async message
def stop(server) do
  GenServer.cast(server, :stop)
end

# Call fn, don't expect a response
def say_hello(server) do
  GenServer.cast(server, :say_hello)
end

# Call, but do want a response
def ping(server) do
  GenServer.call(server, :ping)
end


def connect(server, nick) do
  GenServer.call(server, {:connect, nick})
end

def disconnect(server, nick) do
  GenServer.call(server, {:disconnect, nick})
end

def say(server, nick, msg) do
  GenServer.cast(server, {:say, nick, msg})
end

def whisper(server, nick, receiver, msg) do
  GenServer.cast(server, {:private_message, nick, receiver, msg})
end

#-------------------------------------------------------------------
# GenServer Function Definitions

# Called in response to GenServer.start_link/4. Initialize state
def init(:ok) do
  loadmap("priv/map.bmp")
  { :ok, HashDict.new() }
end

defp loadmap(filename) do
   :true = File.exists?(filename)
   {:ok, data} = File.read(filename)
   img = :binary.bin_to_list(data)
   [66,77, s4,s3,s2,s1, r1,r2,r3,r4, o4,o3,o2,o1|img2] = img
#WORD   FileType;     /* File type, always 4D42h ("BM") */
#DWORD  FileSize;     /* Size of the file in bytes */
#WORD   Reserved1;    /* Always 0 */
#WORD   Reserved2;    /* Always 0 */
#DWORD  BitmapOffset; /* Starting position of image data in bytes */

end

defp broadcast(users, from, msg) do
  Enum.each(users, fn { _, node } -> :gen_server.cast({:message_handler, node}, {:message, from, msg}) end)
end

def handle_call(:ping, _, state) do
  IO.puts("Ping")
  {:reply, :pong, state}
end

def handle_call({:connect, nick}, {pid, _}, users) do
  newusers = users |> HashDict.put(nick, node(pid))
  userlist = newusers |> HashDict.keys |> Enum.join ":"
  {:reply, {:ok, userlist}, newusers}
end

def handle_call({:disconnect, nick}, {pid, _}, users) do
  newusers = users |> HashDict.delete nick
  {:reply, :ok, newusers}
end

def handle_call(_, _, users) do
  IO.puts("handle_call error")
  {:reply, :error, users}
end

def handle_cast({:say, nick, msg}, users) do
  ears = HashDict.delete(users, nick)
  broadcast(ears, nick, "#{msg}")
  {:noreply, users}
end

def handle_cast(:stop, state) do
  IO.puts("WorldServer stopping")
  {:stop, :normal, state }
end

def handle_cast({:private_message, nick, receiver, msg}, users) do
  case users |> HashDict.get receiver do
      nil -> :ok
      r ->
          :gen_server.cast({:message_handler, r}, {:message, nick, "(#{msg})"})
  end
  {:noreply, users}
end

def handle_cast(_, users), do: {:noreply, users}

#------------------------------------------------------------------

# out-of-band msgs
def handle_info(info, state) do
  IO.puts("#{info}")
  {:noreply, state}
end

# invoked by GenServer
def terminate(_reason, _state) do
  IO.puts("WorldServer terminating")
  :ok
end

# Called during release up/down-grade to update internal state
def code_change(_oldVsn, state, _extra) do
  {:ok, state}
end

#------------------------------------------------------------------

end
