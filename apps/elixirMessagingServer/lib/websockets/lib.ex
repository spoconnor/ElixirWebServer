defmodule Lib do

def say(x) do
  spawn(fn() -> :io.format("~s~n",[x]) end)
end
def trace(x) do
  spawn(fn() -> :io.format("~p~n",[x]) end)
end
def trace(x,y) do
  spawn(fn() -> :io.format("~s: ~p~n",[x,y]) end)
end
#def traceBinary(x) do
#  spawn(fn() -> :io.format("~p~n",[b2h(x)]) end)
#end
#def for(max, max, f) do
#  [f(max)]
#end
#def for(i, max, f) do
#  [f(i)|for(i+1, max, f)]
#end
#def b2h(bin) do
#  x = :binary.bin_to_list(bin)
#  :lists.flatten([:io_lib.format("~2.16.0B", x)])
#end
#def h2b(string) do
#  << << (:erlang.list_to_integer([char], 16)):4/integer >> || char <- string >>
#end
#def txt(bin) do
#  [x || <<x>> <= bin,x > 32, x < 127, x !== 45]
#end
#def b2s(bin) do
#  b2s1(:binary.bin_to_list(bin),[])
#end
#def b2s1([],str) do
#  :lists.reverse(str)
#end
#def b2s1([h|t],str) do
#  case h > 32 and h < 127 and h !== 45 do
#  	:true -> b2s1(t,[h,$.|str])
#  	:false -> b2s1(t,[46,46|str])
#  end
#end

#def pmap(f, l, parent) do
#  [for pid <- [for x <- l do spawn(fn() -> send parent, {self(), f.(x)} end) end]
#    do receive do {pid, res}: res end]
#end

def timer(time,fun) do
  spawn(fn() ->
    receive do 
    after
      time -> fun.() 
    end
  end)
end

def signSubtract(a,b) do
  case a<0 do
    :true -> (:erlang.abs(a)-:erlang.abs(b))*-1
    :false -> (:erlang.abs(a)-:erlang.abs(b))
  end
end

def signSubtract1(a,b) do
    case a<0 do
        :true -> (:erlang.abs(a)-b)*-1;
        _ -> (:erlang.abs(a)-b)
    end
end

def floor(x) when x < 0 do
  t = trunc(x)
  case (x - t) === 0 do
    :true -> t;
    :false -> t - 1
  end
end
def floor(x) do
  trunc(x)
end

#def addLen(bin) do
#  len=:erlang.size(bin)+2,
#  <<len:16,bin/binary>>
#end

def datetime_to_unixtime({{_year, _month, _day},{_hour, _min, _sec}}=datetime) do
  unixZero = :calendar.datetime_to_gregorian_seconds({{1970,1,1}, {0,0,0}})
  seconds = :calendar.datetime_to_gregorian_seconds(Datetime)
  seconds - unixZero
end

def unixtime() do
  {megaSecs, secs, _microSecs} = :erlang.now()
  megaSecs * 1000000 + secs
end

def munixtime() do
  {megaSecs, secs, microSecs} = :erlang.now()
  megaSecs * 1000000000 + secs*1000 + (microSecs / 1000)
end

def unique(n) do
  unique(n,[])
end
def unique(0,l) do
  l
end
def unique(n,l) do
  arr = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9','-','_']
  unique(n-1,[:lists.nth(:random.uniform(64),arr)|l])
end

end
