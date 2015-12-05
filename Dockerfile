FROM trenpixster/elixir
MAINTAINER Sean OConnor <onewheel@gmail.com>

############
# My Code

RUN mkdir /opt/ElixirMessagingServer
WORKDIR /opt/ElixirMessagingServer
ADD ElixirMessagingServer/ElixirMessagingServer /opt/ElixirMessagingServer/
RUN mkdir /opt/ElixirMessagingServer/priv
RUN mkdir /opt/ElixirMessagingServer/priv/html5
RUN mkdir /opt/ElixirMessagingServer/priv/html5/resources
ADD Html5Client/src /opt/ElixirMessagingServer/priv/html5
ADD Html5Client/libs /opt/ElixirMessagingServer/priv/html5
ADD Html5Client/resources /opt/ElixirMessagingServer/priv/html5/resources

#RUN wget https://www.dropbox.com/sh/v4xel416t8mcbya/AABPc8LtNHq8c4oRBl-rBVona/ElixirServer.1.0.tgz?dl=0 \
# && tar -xvzf ElixirServer.1.0.tgz -C /opt \
# && rm ElixirServer.1.0.tgz

EXPOSE 80

CMD ["/usr/bin/iex"]
