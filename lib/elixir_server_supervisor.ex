defmodule ElixirServerSupervisor do
use Supervisor

# admin api
def start_link do
    IO.puts "WebserverSupervisor.start_link"
    Supervisor.start_link(__MODULE__,:ok)
end

@riakworker Riak
@webworker WebserverWorker
@es_websock WebsocketWorker
@q_consumer WebsocketQConsumer
@users WebsocketUsers
@worldserverclient WorldServerClient
@worldserverlistener WorldServerListener

# behaviour callbacks
def init(:ok) do
    IO.puts "WebserverSupervisor.init"

    children = [
      #worker(RiakClient, [[name: @riakworker]]),
      worker(WebserverWorker, [[name: @webworker]]),
      worker(WebsocketEsWebsock, [[name: @es_websock]]), 
      worker(WebsocketQConsumer, [[name: @q_consumer]]), 
      worker(WebsocketUsers, [[name: @users]]), 
      #worker(WorldServerClient, [{127,0,0,1}, 8842, [mode: :binary], 3000, [name: @worldserverclient]]),
      worker(WorldServerListener, [[name: @worldserverlistener]]),

      #, [restart: :permanent, shutdown: 1000])
    ]

    supervise(children, strategy: :one_for_one)
end

end
