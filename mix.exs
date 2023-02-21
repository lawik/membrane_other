defmodule MembraneOther.MixProject do
  use Mix.Project

  def project do
    [
      app: :membrane_other,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:membrane_core, "~> 0.10.2"},
      {:membrane_file_plugin, "~> 0.12"}
    ]
  end
end
