defmodule RabbitProducer do

  @exchange      "webserver_exchange"
  @queue         "notify"

  def sendMsg(msg) do
    {:ok, conn} = AMQP.Connection.open
    {:ok, chan} = AMQP.Channel.open(conn)
    AMQP.Basic.publish chan, @exchange, "", msg
  end

end

