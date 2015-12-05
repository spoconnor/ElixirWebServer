defmodule ElixirMessagingServer.Mixfile do
  use Mix.Project

  def project do
    [app: :ElixirMessagingServer,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps,
     escript: escript]  # Comment out to get iex prompt
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: 
      [:logger, :kernel, :stdlib, :lager, :ranch, :cowlib, :cowboy, :jiffy, :ssl, :ibrowse, :inets, :crypto, :riakc ],
      mod: {ElixirMessagingServer, []},
      env: [
        http_port: 8080,
        http_listener_count: 10
      ],
    ]
  end

  def escript do
    [main_module: ElixirMessagingServer]
  end

  defp deps do
    [
      {:cowboy, github: "extend/cowboy", tag: "1.0.1" },
      {:lager, github: "basho/lager", tag: "2.1.1" },
      {:jiffy, github: "davisp/jiffy", tag: "0.13.3" },
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.1" },
      #{:riak_pb, github: "basho/riak_pb", override: true, compile: "./rebar get-deps compile deps_dir=../"},
      {:protobuffs, github: "basho/erlang_protobuffs", override: true, tag: "0.8.1p5" },
      {:riak_pb, github: "basho/riak_pb", override: true, tag: "2.1.0.2" },
      {:riakc, github: "basho/riak-erlang-client", tag: "2.1.1" },
      {:eper, github: "massemanet/eper" , tag: "0.90.0" },
      {:mixer, github: "opscode/mixer", tag: "0.1.1" },
      {:sync, github: "rustyio/sync" }, # Note, in dev
      {:exprotobuf, github: "bitwalker/exprotobuf", tag: "0.11.0"},
      {:gpb, github: "tomas-abrahamsson/gpb", tag: "3.18.8", override: :true},
      {:amqp, github: "pma/amqp", tag: "v0.0.6" },
      {:poison, github: "devinus/poison", tag: "1.4.0"},
      {:connection, github: "fishcakez/connection", tag: "v1.0.1"},
    ]
  end
end
