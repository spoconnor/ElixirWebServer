defmodule WebsocketEventForwarder do
use GenEvent

def handle_event(event, parent) do
  Lib.trace("EventForwarder, handling event...")
  send parent, event
  {:ok, parent}
end

#=== Helper functions ===

def start_manager() do
  GenEvent.start_link
end

def raise_event(manager, event) do
  GenEvent.sync_notify(manager, event)
end


end
