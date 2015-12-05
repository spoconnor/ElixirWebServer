defmodule WorldServerClientTest do
  use ExUnit.Case

  # A simple test
  test "TcpClient" do
    IO.puts("WorldServerClientTest")

    WorldServerClient.start_link(:ok)

    IO.puts("Started")
    assert(:true)
  end


end
