defmodule App.MixProject do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
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
      mod: {App.Application, []},
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
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.6.2"},
      {:ecto_sql, "~> 3.12.1"},
      {:postgrex, ">= 0.19.1"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.17"},
      {:floki, ">= 0.36.3", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.4"},
      {:esbuild, "~> 0.8.2", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.4", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.17.2"},
      {:finch, "~> 0.19.0"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26.1"},
      {:jason, "~> 1.4.4"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5.7"},
      {:resend, "~> 0.4.4"},
      {:ex_aws, "~> 2.5.6"},
      {:ex_aws_s3, "~> 2.5.4"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.7.4"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind app", "esbuild app"],
      "assets.deploy": [
        "tailwind app --minify",
        "esbuild app --minify",
        "phx.digest"
      ]
    ]
  end
end
