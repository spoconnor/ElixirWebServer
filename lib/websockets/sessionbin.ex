defmodule WebsocketSessionBin do

# This code can parse the PHP Session. For now, I'm just using it to see if the session exists
# in order to authenticate a particular name. Authenticated names will show up in a different
# color, while guests can still set nicknames.
#
# binary input
def session(session1) do
  session = :re.replace(session1,<<"[^a-z0-9]+">>,<<"">>,[:global,{:return,:binary}])

  case byte_size(session) do
    26 -> :nil
    _ -> throw("invalid session")
        Lib.trace("Invalid Session")
  end

  case :file.read_file(["/var/lib/php5/sess_", session1]) do
    {:ok,bin} -> parse(bin);
    {:error,_} -> throw("Could Not Load File")
  end
end

def parse(<<>>) do
 :fail
end
def parse(s) do
  parseKey(s,<<>>,[])
end

def parseKey(<<>>,_,list) do
  :lists.reverse(list)
end
# TODO ????
#def parseKey(<<$\|,s/binary>>,key,list) do
#  parseType(s,key,list)
#end
#def parseKey(<<c,s/binary>>,key,list) do
#  parseKey(s,<<key/binary,c>>,list)
#end

def parseType(<<>>,_,_) do
  :fail
end
# TODO ???
#def parseType(<<c,s/binary>>,key,list) do
#  case c do
#    $i ->
#      <<_,s1/binary>> = S,
#      parseInt(s1,key,<<>>,list)
#    $s ->
#      <<$:,s1/binary>> = s
#      parseStrLen(s1,<<>>,key,list)
#  end
#end

#def parseInt([],key,value,list) do
#  [{key,list_to_integer(value)}|list]
#end

# TODO ???
#def parseInt(<<$;,s/binary>>,key,value,list) do
#  parseKey(s,<<>>,[{key,binary_to_integer(value,0)}|list])
#end
#def parseInt(<<c,s/binary>>,key,value,list) do
#  parseInt(s,key,<<value/binary,c>>,list)
#end

# TODO
#def parseStrLen(<<$:,$",t/binary>>,len,key,list) do
#  parseString(binary_to_integer(len,0),t,key,<<>>,list)
#end

#def parseStrLen(<<c,t/binary>>,len,key,list) do
#  parseStrLen(t,<<len/binary,c>>,key,list)
#end

# TODO
#def parseString(0,<<$",$;,s/binary>>,key,value,list) do
#  parseKey(s,<<>>,[{key,value}|list])
#end

#def parseString(amount,<<c,s/binary>>,key,value,list) do
#  parseString(amount-1,s,key,<<value/binary,c>>,list)
#end

def binary_to_integer(<<>>,acc) do
  acc
end
# TODO
#def binary_to_integer(<<num:8,rest/binary>>,acc) when num >= 48 and num < 58 do
# binary_to_integer(rest, acc*10 + (num-48))
#end
#def binary_to_integer(_,acc) do
#  exit({badarg,acc})
#end

end
