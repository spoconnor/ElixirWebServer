defmodule ElixirMessagingServer do
use Application

def main(args) do
  IO.puts "Running..."
  IO.gets(">")
end

def start(_startType, _startArgs) do
  IO.puts "Ensure all started"
  :application.ensure_all_started(ElixirMessagingServer)

  {:ok, _pid} = ElixirServerSupervisor.start_link

  #  IO.puts "Configuring Riak..."
  #  {:ok, _pid} = Riak.start
  #  {:ok, _pid} = Riak.configure([host: '127.0.0.1', port: 8087])

end

def stop(_state) do
  :ok
end

end
