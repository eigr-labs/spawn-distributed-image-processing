# Setting for Evision to use the precompiled version

# Remove if you use a platform on which Evision does not provide a pre-compiled library.
# System.put_env("EVISION_PREFER_PRECOMPILED", "true")

System.put_env("EVISION_PRECOMPILED_CACHE_DIR", "#{System.user_home!()}/.cache")

defmodule SpawnDistributedImageProcessing.MixProject do
  use Mix.Project

  @app :spawn_distributed_image_processing
  @version "0.1.0"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SpawnDistributedImageProcessing.Application, []}
    ]
  end

  defp deps do
    [
      {:spawn_sdk, "~> 0.5.0-alpha.5"},
      {:spawn_statestores_mysql, "~> 0.5.0-alpha.5"},
      {:uniq, "~> 0.5.3"},
      {:nx, "~> 0.3"},
      {:exla, "~> 0.3"},
      {:evision, "~> 0.1.2", github: "cocoa-xu/evision", tag: "v0.1.2"}
    ]
  end
end
