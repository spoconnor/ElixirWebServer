defmodule CommsMessages do
  use Protobuf, from: Path.expand("CommsMessages.proto", __DIR__)
end

