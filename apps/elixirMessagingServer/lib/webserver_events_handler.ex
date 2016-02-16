defmodule WebserverEventsHandler do

def init(_transport, req, _opts) do
    IO.puts "events handler init"
    headers = [{"content-type", "text/event-stream"}]
    {:ok, req2} = :cowboy_req.chunked_reply(200, headers, req)
    :erlang.send_after(1000, self(), {:message, human_readable_date()})
    {:loop, req2, :undefined}
end

def terminate(_reason, _req, _state) do
    :ok
end

def info({message, msg}, req, state) do
    IO.puts "events handler msg recv"
    :ok = :cowboy_req.chunk(["id: date", "\ndata: ", msg, "\n\n"], req)
    :erlang.send_after(1000, self(), {message, human_readable_date()})
    {:loop, req, state}
end

# internal
defp human_readable_date() do
    timeStamp = :os.timestamp()
    {{year, month, day}, {hour, minute, second}} = :calendar.now_to_universal_time(timeStamp)
    dateList = :io_lib.format("~p-~p-~pT~p:~p:~pZ", [year, month, day, hour, minute, second])
    dateList
end

end
