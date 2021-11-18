defmodule Scrip.MixProject do
  use Mix.Project

  @url "https://github.com/maartenvanvliet/scrip"

  def project do
    [
      app: :scrip,
      version: "1.0.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @url,
      homepage_url: @url,
      name: "Scrip",
      description: "Scrip is a library to verify Apple App Store receipts",
      package: [
        maintainers: ["Maarten van Vliet"],
        licenses: ["MIT"],
        links: %{"GitHub" => @url},
        files: ~w(LICENSE README.md lib mix.exs)
      ],
      docs: [
        main: "Scrip",
        canonical: "http://hexdocs.pm/scrip",
        source_url: @url
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1", optional: true},
      {:httpoison, "~> 1.7", only: [:dev, :test]},
      {:ex_doc, "~> 0.22", only: [:dev, :test]},
      {:bypass, "~> 2.1", only: :test},
      {:credo, "~> 1.6.0", only: [:dev, :test], runtime: false}
    ]
  end
end
