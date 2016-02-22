defmodule World.App do
  use Application

  def start(_type, _args) do

    {:ok, _pid} = World.Supervisor.start_link()

  end
end
