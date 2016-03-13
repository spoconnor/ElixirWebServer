@chunkSize 32

defmodule Coord do
  defstruct(
    x: 0,
    y: 0,
  )
end

defmodule ChunkCoord do
  defstruct(
    x: 0,
    y: 0,
  )
end

def coord_to_chunk(%Coord{x: cx, y: cy})
  %ChunkCoord{x: cx / chunkSize, y: cy / chunkSize}
end

def chunk_to_coord(%ChunkCoord{x: cx, y: cy})
  %Coord{x: cx * chunkSize, y: cy * chunkSize}
end
