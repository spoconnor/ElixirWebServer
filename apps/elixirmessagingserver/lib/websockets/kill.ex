defmodule WebsocketKill do

def kill(state,id,message) do
  %WebsocketState{maps: maps, banned: ipBlock, lookupByID: lbid, lookupByName: lbName, lookupByIP: lbip} = state
  {:ok,map}=:dict.find(id,lbid)
  mapDict=:array.get(map,maps)
  {:ok, %WebsocketUser{ip: ip, user: username, pid: pid, sock: sock}} = :dict.find(id,mapDict)
  Websockets.alert(sock,message)
  send pid, {:kill,message}
  :array.foldl(fn(_,dict,_) -> WebsocketEsWebsock.sendToAll(WebsocketWorker, dict,id,["logout @@@ ",username]) end,0,maps)
  maps1=:array.set(map, :dict.erase(id,mapDict),maps)
  lbid1=:dict.erase(id,lbid)
  lbName1=removeID(id,lbName)
  lbip1=removeID(id,lbip)
  ipBlock1=:lists.delete(ip,ipBlock)
  {:noreply,%WebsocketState{maps: maps1, banned: ipBlock1, lookupByID: lbid1, lookupByName: lbName1, lookupByIP: lbip1}}
end
   
def removeID(id,gb) do
  filter=fn({_,id1}) when id1===id -> false;(_) -> true end
  :gb_trees.from_orddict(:lists.filter(filter,:gb_trees.to_list(gb)))
end

end

