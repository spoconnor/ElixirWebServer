mkdir priv/html5
cp ../Html5Client/src/* priv/html5/
cp ../Html5Client/libs/* priv/html5/
cp ../Html5Client/resources priv/html5/ -R
iex --sname servernode --cookie cookie -S mix
