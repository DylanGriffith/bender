defmodule Bender.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bender,
      version: "0.0.5",
      elixir: "~> 1.1",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [applications: [:logger, :httpoison, :poison], mod: {Bender, []}]
  end

  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:poison, "~> 4.0"}
    ]
  end

  defp package do
    [
      files: ["lib", "priv", "mix.exs", "README.md", "LICENSE.txt"],
      maintainers: ["Dylan Griffith"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/DylanGriffith/bender"}
    ]
  end
end
