defmodule BPE.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bpe,
      version: "0.0.1",
      elixir: "~> 1.2",
      elixirc_paths: ["lib"],
      package: [
        maintainers: ["Andreas Deil", "Martin Berger"],
        links: %{"Github" => "https://github.com/itp-world/email-bpe-elixir"},
        licenses: [],
        files: ~w(lib test) ++
               ~w(mix.exs README.md)
      ],
      description: """
      Email delivery engine
      """,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps
   ]
  end

  # Configuration for the OTP application
  # Type "mix help compile.app" for more information
  #
  def application do
    [
      mod: {BPE, []},
      applications: [
        :logger, :timex, :uuid, :quantum, :poolboy, :exq, :tzdata, :httpotion
      ]
    ]
  end

  # Dependencies
  #
  defp deps do
    [
      {:exq,       "~> 0.6.5"},
      #{:exq_ui,    "~> 0.6.5"}, # Disabled in case of potential memory leak in Exq.Middleware.Stats
      {:mailman,   "~> 0.2.2"},
      {:mongodb,   "~> 0.1.1"},
      {:poolboy,   "~> 1.5.1"},
      {:quantum,   ">= 1.7.0"},
      {:uuid,      ">= 1.1.3"},
      {:timex,     ">= 2.1.1"},
      {:httpotion, "~> 2.2.2"}
    ]
  end
end
