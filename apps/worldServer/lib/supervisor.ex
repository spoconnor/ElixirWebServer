defmodule World.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end


# Example usage
#  iex(1)> HelloServer.say_hello(World.HelloServer)
#  Hello
#  :ok


  def init(:ok) do

    children = [
      worker(World.Hello, [[name: World.HelloServer]]),
      worker(World.Server, [[name: World.Server]]),
      worker(World.Map, [[name: World.Map]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
