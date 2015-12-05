defmodule Packet do

  def decode(<<dataSize::8,data::binary>>) do
    msgData = :binary.part(data,0,dataSize)
    Lib.trace("Packet.decoding")
    message = CommsMessages.Message.decode(<<msgData::binary>>)
  end

  def msgType(<<dataSize::8,data::binary>>) do
    msgData = :binary.part(data,0,dataSize)
    message = CommsMessages.Message.decode(<<msgData::binary>>)
    case message.msgtype do
      1 -> "Response"
      2 -> "Ping"
      3 -> "Pong"
      4 -> "NewUser"
      5 -> "Login"
      6 -> "Say"
      7 -> "MapRequest"
      8 -> "MapIgnore"
      9 -> "Map"
     10 -> "MapUpdate"
     11 -> "MapCharacterUpdate"
     12 -> "QueryServer"
     13 -> "QueryServerResponse"
      _ -> "Unknown"
    end
  end

  def encode(message) do
    Lib.trace("Packet.encode")
    bodyData = CommsMessages.Message.encode(message)
    <<byte_size(bodyData)>> <> bodyData
  end

end

