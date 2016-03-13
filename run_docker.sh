mkdir apps/elixirMessagingServer/priv/html5
cp ../ElixirMessagingServer/Html5Client/src/* apps/elixirMessagingServer/priv/html5/
cp ../ElixirMessagingServer/Html5Client/libs/* apps/elixirMessagingServer/priv/html5/
cp ../ElixirMessagingServer/Html5Client/resources apps/elixirMessagingServer/priv/html5/ -R

sudo docker run --name elixirserver -h elixirserver -p 8080-8083:8080-8083 -i -t -v /mnt/archive/Programming/Cloud/ElixirWebServer:/opt/ElixirWebServer trenpixster/elixir:1.1.1 bash
#sudo docker build -t my_elixir_server .
#sudo docker run --name elixirserver -i -t my_elixir_server /opt/ElixirMessagingServer/ElixirMessagingServer
sudo docker rm elixirserver
