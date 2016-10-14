defmodule CookieStore.Mixfile do
  use Mix.Project

  def project do
    [app: :cookie_store,
     name: "CookieStore",
     version: "0.1.0",
     elixir: "~> 1.3",
     description: description(),
     package: package(),
     source_url: "https://github.com/arjan/cookie_store",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  defp description do
    "Library for parsing of HTTP cookies and persistent storage"
  end

  defp package do
    %{files: ["lib", "mix.exs", "*.md", "LICENSE"],
      maintainers: ["Arjan Scherpenisse"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/arjan/cookie_store"}}
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end
end
