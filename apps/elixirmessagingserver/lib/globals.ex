defmodule Globals do

def mq_exchange do "MyExchange" end
def outbound_queue do
  queue = System.get_env("OUTQUEUE")
  if (queue == :nil) do
    "OutboundQueue" 
  else
    queue
  end
end
def inbound_queue do "InboundQueue" end

end
