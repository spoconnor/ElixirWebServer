defmodule ExMessengerClient do

  def main(args) do
    args |> parse_args |> process
  end

  def parse_args(args) do
    switches =
      [
       help: :boolean,
       server: :string,
       nick: :string
      ]

    aliases =
      [
       h: :help,
       s: :server,
       n: :nick
      ]

    options = OptionParser.parse(args, switches: switches, aliases: aliases)

    case options do
      { [ help: true], _, _}            -> :help
      { [ server: server], _, _}        -> [server]
      { [ server: server, nick: nick], _, _} -> [server, nick]
      _                                 -> []
    end
  end

  def process(:help) do
    IO.puts """
      Usage:
        ./ex_messenger_client -s server_name [-n nickname]

      Options:
        -s, --server = fully qualified server name
        -n, --nick   = nickname (optional, you will be promted if not specified)

      Example:
        ./ex_messenger_client -s server@192.168.1.1 -n dr00

      Options:
        -h, [--help]      # Show this help message and quit.
    """
    System.halt(0)
  end

  def process([]) do
    process([nil, nil])
  end

  def process([server]) do
    process([server, nil])
  end

  def process([server, nick]) do

    server = case server do
             nil ->
               IO.write "Server Name: "
               IO.read :line
             n -> n
           end

    server = list_to_atom(bitstring_to_list(String.rstrip(server)))

    IO.puts "Connecting to #{server} from #{Node.self()}..."
    Node.set_cookie(Node.self(), :"chocolate-chip")
    case Node.connect(server) do
      true -> :ok
      reason ->
        IO.puts "Could not connect to server, reason: #{reason}"
        System.halt(0)
    end

    ExMessengerClient.MessageHandler.start_link(server)

    IO.puts "Connected"

    nick = case nick do
             nil ->
               IO.write "Nickname: "
               IO.read :line
             n -> n
           end

    nick = String.rstrip(nick)

    case :gen_server.call({:message_server, server}, {:connect, nick}) do
      {:ok, users} ->
        IO.puts "**Joined the chatroom**"
        IO.puts "**Users in room: #{users}**"
        IO.puts "**Type /help for options**"
      reason ->
        IO.puts "Could not join chatroom, reason: #{reason}"
        System.halt(0)
    end

    # Start gen_server to handle input / output from server
    input_loop([server, nick])
  end

  def input_loop([server, nick]) do
    IO.write "#{Node.self()}> "
    command = IO.read :line
    handle_command(command, [server, nick])

    input_loop([server, nick])
  end

  def handle_command(command, [server, nick]) do
    command = String.rstrip(command)
    case command do
      "/help" ->
        IO.puts """
        Avaliable commands:
          /leave
          /join
          /pm <to nick> <message>
          or just type a message to send
        """
      "/leave" ->
        :gen_server.call({:message_server, server}, {:disconnect, nick})
        IO.puts "You have exited the chatroom, you can rejoin with /join or quit with <Control>-c a"
      "/join" ->
        IO.inspect :gen_server.call({:message_server, server}, {:connect, nick})
        IO.puts "Joined the chatroom"
      "" ->
        :ok
      nil ->
        :ok
      message ->
        if String.contains? message, "/pm" do
          [to|message] = String.split(String.slice(message, 4..-1))
          message = String.lstrip(List.foldl(message, "", fn(x, acc) -> "#{acc} #{x}" end))
          :gen_server.cast({:message_server, server}, {:private_message, nick, to, message})
        else
          :gen_server.cast({:message_server, server}, {:say, nick, message})
        end
    end
  end

end

defmodule ExMessengerClient.MessageHandler do
  use GenServer.Behaviour

  def start_link(server) do
    :gen_server.start_link({ :local, :message_handler }, __MODULE__, server, [])
  end

  def init(server) do
    { :ok, server }
  end

  def handle_call(_, _, server), do: {:reply, :error, server}

  def handle_cast({:message, nick, msg}, server) do
    msg = String.rstrip(msg)
    IO.puts "\n#{server}> #{nick}: #{msg}"
    IO.write "#{Node.self()}> "
    {:noreply, server}
  end

  def handle_cast(_, server), do: {:noreply, server}
end
