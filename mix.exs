defmodule EasyFixApi.Mixfile do
  use Mix.Project

  def project do
    [app: :easy_fix_api,
     version: "0.0.2",
     elixir: "~> 1.5",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  def application do
    [mod: {EasyFixApi.Application, []},
     extra_applications: [:logger, :runtime_tools, :inets]
   ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.3", override: true},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},

      {:nimble_csv, "~> 0.1.0"},
      {:comeonin, "~> 3.0"},
      {:guardian, "~> 0.14"},
      {:corsica, "~> 1.0"},
      {:ecto_enum, "~> 1.0"},
      {:gen_state_machine, "~> 2.0"},
      {:timex, "~> 3.1"},
      {:bamboo, "~> 0.8"},
      {:money, "~> 1.2.1"},
      {:hashids, "~> 2.0"},
      {:tesla, "~> 0.9.0"},

      {:ex_machina, "~> 2.0", only: [:dev, :test]},

      {:edeliver, "~> 1.4.4"},
      {:distillery, "~> 1.5", runtime: false},
   ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.create", "ecto.migrate"],
      "ecto.reseed": ["ecto.reset", "run priv/repo/seeds.exs"],
    ]
  end
end
