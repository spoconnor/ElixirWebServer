defmodule ElixirMessagingServer.Mixfile do
  use Mix.Project

  def project do
    [app: :elixirMessagingServer,
     version: "0.0.1",
     elixir: "~> 1.1.1",
     build_path: "../../build",
     deps: deps,
     deps_path: "../../deps",
     config_path: "../../config/config.exs",
     lockfile: "../../mix.lock",
     escript: escript]  # Comment out to get iex prompt
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: 
      [:logger, :kernel, :stdlib, :lager, :cowlib, :cowboy, :jiffy, :ssl, :ibrowse, :inets, :crypto ],
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
      #{:anotherproject, in_umbrella: true},
      {:cowboy, "~> 1.0.1" },
      #{:lager, github: "basho/lager", tag: "2.1.1" },
      {:goldrush, "== 0.1.6" },
      {:lager, "~> 2.1.1" },
      {:jiffy, github: "davisp/jiffy", tag: "0.13.3" },
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.2.2" },
      #{:riak_pb, github: "basho/riak_pb", override: true, compile: "./rebar get-deps compile deps_dir=../"},
      {:protobuffs, github: "basho/erlang_protobuffs", override: true, tag: "0.8.1p5" },
      #{:riak_pb, github: "basho/riak_pb", override: true, tag: "2.1.0.7" },
      #{:riakc, github: "basho/riak-erlang-client", tag: "2.1.1" },
      {:eper, github: "massemanet/eper" , tag: "0.96.4" },
      {:mixer, github: "opscode/mixer", tag: "0.1.1" },
      {:sync, github: "rustyio/sync" }, # Note, in dev
      #{:exprotobuf, github: "bitwalker/exprotobuf", tag: "0.11.0"},
      {:exprotobuf, "~> 0.11.0"},
      #{:gpb, github: "tomas-abrahamsson/gpb", tag: "3.18.8", override: :true},
      {:gpb, "~> 3.18.8"},
      #{:amqp, github: "pma/amqp", tag: "v0.0.6" },
      #{:poison, github: "devinus/poison", tag: "1.4.0"},
      {:poison, "~> 1.4.0"},
      #{:connection, github: "fishcakez/connection", tag: "v1.0.1"},
      {:connection, "~> 1.0.1"},
    ]
  end
end
