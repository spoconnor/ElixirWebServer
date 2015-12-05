defmodule WebsocketMove do

def move(%WebsocketSimple{id: id, map: map},x,y,state = %WebsocketState{maps: maps})  do
  mapDict=:array.get(map,maps)
  now=Lib.munixtime()
  case :dict.find(id,mapDict) do
    {:ok, record=%WebsocketUser{lastAction: lastAction, user: user}} when (now-lastAction)>349 ->
      newMaps=:array.set(map,:dict.store(id,%WebsocketUser{lastAction: now, x: x, y: y},mapDict),maps)
      WebsocketEsWebsock.sendToAll(WebsocketWorker, mapDict,id,["move @@@ ",user,"||",x,"||",y])
      {:noreply,%WebsocketState{maps: newMaps}}
    _ -> {:noreply,state}
  end
end

end
