defmodule WebsocketState do
  defstruct(
    maps:  :array.new(2,{:default,:dict.new()}),
    increment:  0,
    lookupByID:  :dict.new(),
    lookupByName:  :gb_trees.empty(),
    lookupByIP:  :gb_trees.empty(),
    banned:  [],
    sock:  nil
  )
end

