defmodule Leap.MixProject do
  use Mix.Project

  def project do
    [
      app: :leap,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Leap.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # PHOENIX
      {:phoenix, "~> 1.5"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_live_view, "~> 0.14"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.1"},
      # ECTO
      {:ecto_sql, "~> 3.1"},
      {:ecto_enum, "~> 1.4"},
      {:postgrex, ">= 0.0.0"},
      # MARKDOWN
      {:html_sanitize_ex, "~> 1.3.0"},
      {:earmark, "~> 1.4.3"},
      # AUTHENTICATION
      {:pow, "~> 1.0"},
      {:pow_postgres_store, "~> 1.0.0-rc2"},
      {:pow_assent, "~> 0.4"},
      {:certifi, "~> 2.4"},
      {:ssl_verify_fun, "~> 1.1"},
      {:mint, "~> 1.0"},
      {:castore, "~> 0.1"},
      # MAILER
      {:swoosh, "~> 0.25"},
      # AUTHORIZATION
      {:bodyguard, "~>2.4"},
      # TOOLS
      {:typed_struct, "~> 0.1.4"},
      {:machinery, "~> 1.0.0"},
      {:timex, "~> 3.6"},
      # TESTING
      {:floki, ">= 0.0.0", only: :test},
      {:faker, "~> 0.14", only: :test},
      {:ex_machina, "~> 2.4", only: :test, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
