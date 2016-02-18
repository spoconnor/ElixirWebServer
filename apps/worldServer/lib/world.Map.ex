defmodule WorldServer.Map do
  use GenServer

# Call with
# WorldServer.Map.lookup WorldServer.Map, "Hey"

@doc """
Starts the Map worker with the given name
"""
def start_link(name) do
  GenServer.start_link(__MODULE__, :ok, name: name)
end

def lookup(server, name) do
  GenServer.call(server, {:lookup, name})
end

def create(server, name) do
  GenServer.cast(server, {:create, name})
end

def init(:ok) do
  {:ok, %{}}
end

def handle_call({:lookup, name}, _from, state) do
  {:reply, "hello", state}
end

def handle_cast({:create, name}, state) do
  {:noreply, state}
end

end
