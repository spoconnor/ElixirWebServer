defmodule WebsocketSay do

def flood do
  2000
end

def say(%WebsocketSimple{id: id, map: map},message,state = %WebsocketState{maps: maps}) do
  Lib.trace("Websocket.say", message)
  mapDict=:array.get(map,maps)
  say1({id,map,mapDict,message,maps}, :dict.find(id,mapDict),state)
end

def say1({id,map,mapDict,message,maps},{:ok, record},state) do
  %WebsocketUser{lastMessage: lastMessage, floodTest: [_|floodTest], user: user, sock: sock} = record
  unix=Lib.munixtime()
  waited=unix - lastMessage
  difference=waited - flood
  case waited > flood do 
    :true ->
      WebsocketEsWebsock.sendToAll(WebsocketWorker, mapDict,id,["say @@@ ",user,"||",message]);
    :false ->
      :websockets.alert(sock,["Error: Flooding, message not sent, wait ",flood - difference," more seconds."])
  end
  floodTest1=floodTest ++ [difference]
  {len,sum} = :lists.foldl(fn(x,{len,sum}) -> {len+1,sum+x} end,{0,0},floodTest1)
  test = sum / len
#  Lib.trace("Flood Test",test)
  case test<1000 do
    :false ->
      newDict=:dict.store(id,%WebsocketUser{floodTest: floodTest1, lastMessage: unix, lastAction: unix},mapDict)
      newMap=:array.set(map,newDict,maps)
      {:noreply,%WebsocketState{maps: newMap}}
    :true ->
      %WebsocketState{banned: banned} = state
      %WebsocketUser{ip: ip} = record
      newState=%WebsocketState{banned: [ip|banned]}
      Kill.kill(newState,id,"Excess Flooding, you have been banned")
  end
end

def say1(_,_,state) do
  state
end

end
