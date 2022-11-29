defmodule Exical.MixProject do
  use Mix.Project

  def project do
    [
      app: :exical,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Exical",
      docs: docs(),
      description: description(),
      package: package(),
      source_url: "https://github.com/MigaduMail/exical"
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
      {:exsync, "~> 0.2", only: :dev},
      {:timex, "~> 3.7"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "Exical",
      extras: ["README.md"],
      source_ref: "v0.1.0"
    ]
  end

  def description do
    "Library for parsing iCalendar files in elixir structs."
  end

  def package do
    [
      mainteiners: ["dimitrijedimitrijevic", "swerter", "Dimitrije Dimitrijevic", "Michael Bruderer"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/MigaduMail/exical"}
    ]
  end
end
