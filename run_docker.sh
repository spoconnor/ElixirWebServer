sudo docker run --name elixirserver -i -t -v /mnt/archive/Programming/Cloud/ElixirWebServer:/opt/ElixirWebServer trenpixster/elixir:1.1.1 bash
#sudo docker build -t my_elixir_server .
#sudo docker run --name elixirserver -i -t my_elixir_server /opt/ElixirMessagingServer/ElixirMessagingServer
sudo docker rm elixirserver
