defmodule WebsocketUsers do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def add_user(server, user, notify_pid) do
    GenServer.cast(server, {:add, user, notify_pid})
  end

  def notify(server, payload) do
    GenServer.cast(server, {:notify, payload})
  end

  def init(:ok) do
    Lib.trace("Starting WebsocketUsers")
    users = HashDict.new
    {:ok, users}
  end

  def handle_cast({:add, user, notify_pid}, users) do
    Lib.trace("Adding user #{user}")
    newUsers = HashDict.put(users, user, notify_pid)
    {:noreply, newUsers}
  end

  def handle_cast({:notify, payload}, users) do
    #todo
    Lib.trace("Notifying users", payload)
    data = Packet.decode(payload)
    Lib.trace("MessageType:", data.msgtype)
#    actions(payload, msg)
#    notify_users(payload, data.dest, users)
    # TODO - for now, just send to everyone
    notify_users(payload, "", users)
    {:noreply, users}
  end

  # Send to all users
  defp notify_users(payload, "", users) do
    Enum.each users, fn {user, notify_pid} -> 
      Lib.trace("Sending notify to #{user}")
      send notify_pid, payload
    end
    {:noreply, users}
  end

  # Send to a specified user
  defp notify_users(payload, dest, users) do
    {user, notify_pid} = Enum.find(users, fn {user, _notify_pid} -> user == dest end)
    Lib.trace("Sending notify to #{user}")
    send notify_pid, payload
    {:noreply, users}
  end

#  defp actions(%CommsMessages.Say{from: from, target: target, text: text}, users) do
#    Lib.trace("Action: say")
#    Lib.trace("#{msg.from}, #{msg.target}, #{msg.say}")
#  end

  defp actions(_unknown, users) do
    Lib.trace("Action: Unknown!")
  end
end

