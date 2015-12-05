defmodule WebserverWorker do
use GenServer

# Client API

 def start_link(opts \\ []) do
  IO.puts "Starting Webserver Worker..."
  GenServer.start_link(__MODULE__, :ok, opts)
 end

 def stop() do
  GenServer.call(:stop)
 end

# Server Callbacks

 def init(:ok) do
  IO.puts "Starting cowboy worker..."

  port = Application.get_env(:ElixirMessagingServer, :http_port)
  listenerCount = Application.get_env(:ElixirMessagingServer, :http_listener_count)
  IO.puts("Listening on port #{port}")

  dispatch =
    :cowboy_router.compile([
       {
         :_,
         [
            {"/html5/CommsMessages.proto", :cowboy_static, {:priv_file, :ElixirMessagingServer, "html5/CommsMessages.proto", [{:mimetypes, {<<"text">>, <<"plain">>, []}}]}},
            {"/html5/[...]", :cowboy_static, {:priv_dir, :ElixirMessagingServer, "html5", 
              [{:mimetypes, :cow_mimetypes, :all}]
            }},
            {"/events", WebserverEventsHandler, []},
            {"/foobar", WebserverFoobarHandler, []},
            #{"/api", WebserverRestApiHandler, []},
            #{"/ws", :cowboy_static, {:file, "priv/ws_index.html"}},
            #{"/websocket", WebserverWebsocketHandler, []},
            #{"/static/[...]", :cowboy_static, {:priv_dir, :ElixirMessagingServer, "static"}},
            #{"/api/[:id]", [{:v1, :int}], WebserverToppageHandler, []},
            #{"/[...]", :cowboy_static, {:file, "html5/index.html"}},
         ]
       }
    ])
  ranchOptions =
    [ 
      {:port, port}
    ]
  cowboyOptions =
    [ 
      {:env, [
         {:dispatch, dispatch}
      ]},
      {:compress,  true},
      {:timeout,   12000}
    ]
    
  {:ok, _} = :cowboy.start_http(:http, listenerCount, ranchOptions, cowboyOptions)

  {:ok, {}}
 end

 def handle_call(:stop, _from, state) do
  {:stop, :normal, :ok, state}
 end

end


