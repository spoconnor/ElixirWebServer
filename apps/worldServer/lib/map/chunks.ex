defmodule Chunks do
use GenServer

#-------------------------------------------------------------------
# GenServer Function Definitions

def start_link(opts) do
  GenServer.start_link(__MODULE__, :ok, opts)
end

def stop() do
  GenServer.call(:stop)
end

#-------------------------------------------------------------------

def init([x,y]) do
  IO.puts("Chunks initializing with size #{x},#{y}")
  chunks = HashDict.new
  {:ok, %{xsize: x, ysize: y, chunks: chunks} }
end

def terminate(_reason, _state) do
  IO.puts("Chunks terminating")
  :ok
end

#def code_change(_oldVsn, state, _extra) do
#  {:ok, state}
#end

def get(server, x,y) do
  GenServer.call(server, {:get, x,y})
end

#-------------------------------------------------------------------

defp index(state, x,y) do
  y * state.xsize + x
end

defp create_chunk() do
  "wibble"
end

def handle_call({:get, x,y}, _from, state) do
  if HashDict.has_key?(state.chunks, index(state, x,y)) do
    IO.puts("Getting Chunk #{x},#{y}")
    {:ok, chunk} = HashDict.fetch(state.chunks, index(state, x,y))
    {:reply, chunk, state}
  else
    IO.puts("Creating Chunk #{x},#{y}")
    chunk = create_chunk()
    chunks = HashDict.put(state.chunks, index(state, x,y), chunk)
    {:reply, chunk, %{state | chunks: chunks} }
  end
end

#------------------------------------------------------------------

end
