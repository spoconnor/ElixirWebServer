defmodule WorldServerClient do
  use Connection

  def start_link(host, port, opts, timeout \\ 5000) do
    Connection.start_link(__MODULE__, {host, port, opts, timeout})
  end

  def init({host, port, opts, timeout}) do
    state = %{host: host, port: port, opts: opts, timeout: timeout, sock: nil}
    {:connect, :init, state}
  end


  def send(server, msg) do
    Lib.trace("WorldServerClient send")
    Connection.call(server, {:send,msg})
  end

  def recv(server, bytes, timeout \\ 3000) do
    Lib.trace("WorldServerClient recv")
    Connection.call(server, {:recv,bytes,timeout})
  end

  def close(server) do
    Connection.call(server, :close)
  end


  def connect(_info, %{sock: nil, host: host, port: port, opts: opts, timeout: timeout} = state) do
    case :gen_tcp.connect(host, port, [active: false] ++ opts, timeout) do
      {:ok, sock} ->
        Lib.trace("WorldServerClient.init: Connected")
        {:ok, %{state | sock: sock}}
      {:error, reason} ->
        Lib.trace("WorldServerClient.init: Connection failed - #{inspect reason}")
        {:backoff, 5000, state} # try again in 5 seconds
    end
  end

 def disconnect(info, %{sock: sock} = state) do
    :ok = :gen_tcp.close(sock)
    case info do
      {:close, from} ->
        Lib.trace("WorldServerClient Close connection")
        Connection.reply(from, :ok)
      {:error, :closed} ->
        Lib.trace("WorldServerClient Error Connection closed")
      {:error, reason} ->
        reason = :inet.format_error(reason)
        Lib.trace("WorldServerClient Disconnect error - #{inspect reason}")
    end
    {:connect, :reconnect, %{state | sock: :nil}}
  end


  def handle_call(_, _, %{sock: :nil} = state) do
    Lib.trace("WorldServerClient connection is closed")
    {:reply, {:error, :closed}, state}
  end
  def handle_call({:send, data}, _, %{sock: sock} = state) do
    Lib.trace("WorldServerClient sending data")
    case :gen_tcp.send(sock, data) do
      :ok ->
        {:reply, :ok, state}
      {:error, _} = error ->
        {:disconnect, error, error, state}
    end
  end
  def handle_call({:recv, bytes, timeout}, _, %{sock: sock} = state) do
    Lib.trace("WorldServerClient waiting for recv")
    case :gen_tcp.recv(sock, bytes, timeout) do
      {:ok, _} = ok ->
        {:reply, ok, state}
      {:error, :timeout} = timeout ->
        {:reply, timeout, state}
      {:error, _} = error ->
        {:disconnect, error, error, state}
    end
  end
  def handle_call(:close, from, state) do
    {:disconnect, {:close, from}, state}
  end

end

