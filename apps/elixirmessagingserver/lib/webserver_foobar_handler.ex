defmodule WebserverFoobarHandler do

def init(_transport, _req, _opts) do
  IO.puts "foobar handler init"
  {:upgrade, :protocol, :cowboy_rest}
end

def allowed_methods(req, state) do
  {["GET"], req, state}
end

def content_types_provided(req, state) do
  {[{"application/json", :handle_get}], req, state}
end

def is_authorized(req, state) do
  {:true, req, state}
end


def handle_get(req, state) do
  IO.puts "foobar handle get"
  body = :jiffy.encode({[{:foo, :bar}]})
  {body, req, state}
end

end


