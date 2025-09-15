defmodule BasicGrpcService.MixProject do
  use Mix.Project

  def project do
    [
      app: :basic_grpc_service,
      version: "0.1.0",
      elixir: "~> 1.17",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {BasicGrpcService.Application, []},
      extra_applications: [:logger, :grpc, :protobuf]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:grpc, "~> 0.10"},
      {:protobuf, "~> 0.14"},
      {:grpc_reflection, "~> 0.2"}
    ]
  end
end
