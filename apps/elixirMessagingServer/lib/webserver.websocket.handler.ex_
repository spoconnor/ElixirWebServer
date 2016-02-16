defmodule Webserver.Websocket.Handler do
#@behaviour :cowboy_websocket_handler
@behaviour :cowboy_http_handler
@behaviour :cowboy_http_websocket_handler

# Behaviour cowboy_http_handler
#-export([init/3, handle/2, terminate/2]).

# Behaviour cowboy_http_websocket_handler
#-export([
#  websocket_init/3, websocket_handle/3,
#  websocket_info/3, websocket_terminate/3
#]).

#def init(_transport, req, []) do
#  IO.puts("Websocket Handler init")
#  {:cowboy_websocket, req, []}
#end

#def websocket_handle({:text, msg}, req, state) do
#  IO.puts("Websocket Handle received text")
#  {:reply, {:text, << "That's what she said! ", msg >>}, req, state}
#end
#
#def websocket_handle(_data, req, state) do
#  IO.puts("Websocket Handle received data")
#  {:ok, req, state}
#end
#
#def websocket_info({:timeout, _ref, msg}, req, state) do
#  IO.puts("Websocket info")
#  :erlang.start_timer(1000, self(), <<"How' you doin'?">>)
#  {:reply, {:text, msg}, req, state}
#end
#
#def websocket_info(_info, req, state) do
#  IO.puts("Websocket info")
#  {:ok, req, state}
#end


# Called to know how to dispatch a new connection.
def init({:tcp, :http}, req, _opts) do
  IO.puts("Init Request:")
  IO.puts("#{req}")
  # "upgrade" every request to websocket,
  # we're not interested in serving any other content.
  {:upgrade, :protocol, :cowboy_http_websocket}
end

# Should never get here.
def handle(req, state) do
  IO.puts("Unexpected request:")
  IO.puts([req])
  {:ok, req2} = :cowboy_http_req.reply(404, [
    {'Content-Type', <<"text/html">>}
  ])
  {:ok, req2, state}
end

def terminate(_req, _state) do
  :ok
end

# Called for every new websocket connection.
def websocket_init(_any, req, []) do
  IO.puts("New client")
  req2 = :cowboy_http_req.compact(req)
  {:ok, req2, :undefined, :hibernate}
end

# Called when a text message arrives.
def websocket_handle({:text, msg}, req, state) do
  IO.puts("Received")
  IO.puts([msg])
  {:reply,
    {:text, << "Responding to ", msg/:binary >>},
    req, state, :hibernate
  }
end

# With this callback we can handle other kind of
# messages, like binary.
def websocket_handle(_any, req, state) do
  {:ok, req, state}
end

# Other messages from the system are handled here.
def websocket_info(_info, req, state) do
  {:ok, req, state, :hibernate}
end

def websocket_terminate(_reason, _req, _state) do
  :ok
end


end



