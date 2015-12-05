defmodule WebserverRestApiImageHandler do

def init(_transport, req, []) do
  # For the random number generator:
  :random.seed(:erlang.now)

  # Specify handler based on request method
  case :cowboy_req.method(req) do
    {"POST", _}   -> {:upgrade, :protocol, :cowboy_rest}
    {"GET", req1} -> handle_get(req1)
  end
end

def allowed_methods(req, state) do
  {["POST"], req, state}
end

def content_types_accepted(req, state) do
  {
   [ 
     {{"image", "jpeg", []}, :handle_post}
   ], req, state
  }
end

def terminate(_reason, _req, _state) do
  :ok
end

def handle_post(req, state) do
  IO.puts "Handle Post..."
  {method, req2} = :cowboy_req.method(req)
  {id, req3} = :cowboy_req.qs_val("id", req2)
  {:ok, req4} = store_image(method, id, req3)
  {:ok, req4, state}
end

def store_image("POST", :undefined, req) do
  :cowboy_req.reply(400, [], "Missing image parameter.", req)
end
def store_image("POST", id, req) do
  IO.puts "Storing #{id}"
  IO.puts req
  :cowboy_req.reply(200, [
    {"content-type", "text/plain; charset=utf-8"}
  ], id, req)
end
def store_image(_, _, req) do
  # Method not allowed.
  :cowboy_req.reply(405, req)
end

def handle_get(req) do
  # set the response encoding properly for SSE
  {:ok, req1} = :cowboy_req.chunked_reply(
    200, 
    [{"content-type", "text/event-stream"}], req)

  # get latest data from database
  datalist = {"blah...", "test", "wibble"}

  # send each in the response
  :lists.foreach(
    fn(data) ->
      send_data(data, req1)
    end, datalist)

  # Instruct cowboy to start looping and hibernate until a message is recv
  {:loop, req1, :undefined, :hibernate}
end

def send_data(data, req) do
 #todo
 :ok
end

#def handle(Req, State) do
#  Port = open_port({spawn, "/opt/vc/bin/raspistill -t 2 -w 1024 -h 768 -o -"}, [binary])
#  Str = loop(Port,<<>>) 
#  {ok, Req2} = cowboy_req:reply(200, [], Str, Req)
#  {ok, Req2, State}
#end
#
#def terminate(_Reason, _Req, _State) do
#  ok
#end
#
#def loop(Port,Frame) do
#  receive			
#    {Port, {data, Chunk}} -> 
#      Size = byte_size(Chunk) - 2
#      case Chunk do 
#        <<_:Size/binary,255,217>> -> Framestring = base64:encode_to_string(<<Frame/binary,Chunk/binary>>)
#                  "<html><img src = 'data:image/jpeg;base64," ++ Framestring ++ "'></html>"
#      end
#    _ -> loop(Port,<<Frame/binary,Chunk/binary>>)
#  end
#  after 20*1000 -> "<html>timeout</html>"
#  end
#end


end
