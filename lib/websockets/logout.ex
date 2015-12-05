defmodule WebsocketLogout do

def logout(%WebsocketSimple{id: id, map: map},state = %WebsocketState{maps: maps, lookupByID: lbid, lookupByName: lbName, lookupByIP: lbip}) do
  mapDict=:array.get(map,maps)
  case :dict.find(id,mapDict) do
    {:ok, %WebsocketUser{user: user, pid: pid, ip: ip}} ->
        send pid, {:die,"Disconnected"}
        WebsocketEsWebsock.sendToAll(WebsocketWorker, mapDict,id,["logout @@@ ",user])
        lbid1=:dict.erase(id,lbid)
        lbip1=:gb_trees.delete_any(ip,lbip)
        lbName1=:gb_trees.delete_any(user,lbName)
        {:noreply, %WebsocketState{maps: :array.set(map, :dict.erase(id,mapDict),maps), lookupByID: lbid1, lookupByName: lbName1, lookupByIP: lbip1}}
    _ -> {:noreply,state}
  end
end

end
