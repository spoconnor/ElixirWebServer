defmodule HelloServer do
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
# iex(1)> {:ok,pid}=HelloServer.start_link
# {:ok, #PID<0.84.0>}
# iex(2)> HelloServer.say_hello(pid)
# Hello
# :ok
# iex(4)> HelloServer.get_count(pid)
# 2
# iex(5)> HelloServer.get_count(pid)
# 3

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
def get_count(server) do
  GenServer.call(server, :get_count)
end

#-------------------------------------------------------------------
# GenServer Function Definitions

# Called in response to GenServer.start_link/4. Initialize state
def init(:ok) do
  IO.puts("HelloServer initializing")
  {:ok, %State{count: 0}}
end

# synchronously response with count, and update state
def handle_call(:get_count, _from, %State{count: count}) do 
  {:reply, count, %State{count: count+1} }
end

# deal with Stop request
def handle_cast(:stop, state) do
  IO.puts("HelloServer stopping")
  {:stop, :normal, state }
end

# async call, with no reply
def handle_cast(:say_hello, state) do
  IO.puts("Hello")
  {:noreply, %State{count: state.count+1} }
end

# out-of-band msgs
def handle_info(info, state) do
  IO.puts("#{info}")
  {:noreply, state}
end

# invoked by GenServer
def terminate(_reason, _state) do
  IO.puts("HelloServer terminating")
  :ok
end

# Called during release up/down-grade to update internal state
def code_change(_oldVsn, state, _extra) do
  {:ok, state}
end

#------------------------------------------------------------------

end
