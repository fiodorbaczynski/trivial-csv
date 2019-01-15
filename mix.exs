defmodule TrivialCsv.MixProject do
  use Mix.Project

  def project do
    [
      app: :trivial_csv,
      version: "0.0.1-alpha",
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: "Trivial CSV",
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Fiodor Baczyński"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/fiodorbaczynski/trivial-csv"}
    ]
  end

  defp deps do
    [
      {:csv, "~> 2.0.0"}
    ]
  end
end
