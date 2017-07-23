defmodule EasyFixApi.Mixfile do
  use Mix.Project

  def project do
    [app: :easy_fix_api,
     version: "0.0.1",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  def application do
    [mod: {EasyFixApi.Application, []},
     extra_applications: [:logger, :runtime_tools]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.3.0-rc", override: true},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:nimble_csv, "~> 0.1.0"},
      {:cowboy, "~> 1.0"},
      {:comeonin, "~> 3.0"},
      {:guardian, "~> 0.14"},
      {:ex_machina, "~> 2.0", only: [:dev, :test]},
   ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.reseed": ["ecto.drop", "ecto.setup", "run priv/repo/static_data/seeds.exs"],
    ]
  end
end
