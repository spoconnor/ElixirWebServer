defmodule World.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @hello_server_name WORLD.HelloServer
  @world_server_name WORLD.WORLDServer


# Example usage
#  iex(1)> HelloServer.say_hello(WORLD.HelloServer)
#  Hello
#  :ok


  def init(:ok) do

    children = [
      worker(HelloServer, [[name: @hello_server_name]]),
      worker(WorldServer, [[name: @world_server_name]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
