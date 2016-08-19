defmodule World.Map do
use GenServer

defmodule State do
 defstruct(
   count: 0
 )
end

#-------------------------------------------------------------------
# API Function Definitions
#
# Example Usage
#
# iex(1)> {:ok,pid}=MapServer.start_link
# {:ok, #PID<0.84.0>}
# iex(2)> MapServer.say_hello(pid)
# Hello
# :ok
# iex(4)> MapServer.get_count(pid)
# 2
# iex(5)> MapServer.get_count(pid)
# 3

# spawn and links to new process in one atomic step
def start_link(opts \\ []) do
  GenServer.start_link( __MODULE__, :ok, opts)
end

# Use cast to send async message
def stop(server) do
  GenServer.cast(server, :stop)
end

#-------------------------------------------------------------------

# Call fn, don't expect a response
def say_hello(server) do
  GenServer.cast(server, :say_hello)
end

def register(server, coord) do
  GenServer.cast(server, :register, coord)
end

def deregister(server, coord) do
  GenServer.cast(server, :deregister, coord)
end

def get_map(server, coord) do
  GenServer.call(server, :get_map, coord)
end

def set_block(server, coord, block) do
  GenServer.call(server, :set_block, coord, block)
end

def get_block(server, coord) do
  GenServer.call(server, :get_block, coord)
end



#-------------------------------------------------------------------
# GenServer Function Definitions

# Called in response to GenServer.start_link/4. Initialize state
def init(:ok) do
  IO.puts("MapServer initializing")
  {:ok,chunks_pid}=MapServer.start_link
  {:ok, chunks_pid}
end

# deal with Stop request
def handle_cast(:stop, state) do
  IO.puts("MapServer stopping")
  {:stop, :normal, state }
end

# out-of-band msgs
def handle_info(info, state) do
  IO.puts("#{info}")
  {:noreply, state}
end

# invoked by GenServer
def terminate(_reason, _state) do
  IO.puts("MapServer terminating")
  :ok
end

# Called during release up/down-grade to update internal state
def code_change(_oldVsn, state, _extra) do
  {:ok, state}
end

#------------------------------------------------------------------

# async call, with no reply
def handle_cast(:say_hello, state) do
  IO.puts("Hello")
  {:noreply, state }
end

def handle_cast({:register, coord}, state) do
  IO.puts("register")
  {:noreply, state }
end

def handle_cast({:deregister, coord}, state) do
  IO.puts("deregister")
  {:noreply, state }
end

def handle_call({:get_map, coord}, from, state) do
  IO.puts("get_map")
  map = Chunks.get(state, coord)
  {:reply, map, state }
end

def handle_call({:set_block, coord, block}, from, state) do
  IO.puts("set_block")
  Chunks.set(state, coord, block)
  {:reply, :ok, state }
end

def handle_call({:get_block, coord}, from, state) do
  IO.puts("get_block")
  block = Chunks.get(state, coord)
  {:reply, block, state }
end

#------------------------------------------------------------------
end
