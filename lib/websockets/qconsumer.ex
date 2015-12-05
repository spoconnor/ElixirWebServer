defmodule WebsocketQConsumer do
  use GenServer
  use AMQP

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, conn} = Connection.open("amqp://guest:guest@localhost")
    {:ok, chan} = Channel.open(conn)

    #Basic.qos(chan, prefetch_count: 10) # Limit unacknowledged messages to 10
    #Lib.trace("Declaring queue", Globals.recv_queue)
    #Queue.declare(chan, Globals.recv_queue, [durable: false, auto_delete: true, exclusive: false])
    ## Messages that cannot be delivered to any consumer in 
    ## the main queue will be routed to the error queue
    #Lib.trace("Declaring queue", Globals.error_queue)
    #Queue.declare(chan, Globals.error_queue, durable: false, arguments: [
    #  {"x-dead-letter-exchange", :longstr, ""}, 
    #  {"x-dead-letter-routing-key", :longstr, Globals.error_queue}])
    #:ok = Exchange.declare(chan, Globals.mq_exchange, :direct, [auto_delete: true, durable: false])
    #Queue.bind(chan, Globals.recv_queue, Globals.mq_exchange)

    # Register the GenServer process as a consumer
    Basic.consume(chan, Globals.outbound_queue)
    {:ok, chan}
  end

  def handle_info({payload, %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    spawn fn -> consume(chan, tag, redelivered, payload) end
    {:noreply, chan}
  end

  defp consume(channel, tag, redelivered, payload) do
    try do
      Lib.trace("Received msg from queue", payload)
      WebsocketUsers.notify(WebsocketUsers, payload)
      Basic.ack channel, tag
      #Basic.reject channel, tag, requeue: false
    rescue
      exception ->
        # Requeue unless it's a redelivered message.
        # This means we will retry consuming a message once in case of exception
        # before we give up and have it moved to the error queue
        Basic.reject channel, tag, requeue: not redelivered
        Lib.trace("Error reading:", payload)
        Lib.trace(Exception.message(exception))
    end
  end

end

