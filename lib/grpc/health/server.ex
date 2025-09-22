defmodule Health.Server do
  @moduledoc "gRPC health server"

  use GRPC.Server, service: Grpc.Health.V1.Health.Service, http_transcode: true

  require Logger

  alias GRPC.Stream

  alias Grpc.Health.V1.{
    HealthCheckRequest,
    HealthCheckResponse,
    HealthListRequest,
    HealthListResponse
  }

  @spec check(HealthCheckRequest.t(), GRPC.Server.Stream.t()) :: any()
  def check(request, _stream) do
    Stream.unary(request)
    |> Stream.map(fn _ ->
      %HealthCheckResponse{status: :SERVING}
    end)
    |> Stream.run()
  end

  @spec list(HealthListRequest.t(), GRPC.Server.Stream.t()) :: any()
  def list(request, _stream) do
    Stream.unary(request)
    |> Stream.map(fn _ ->
      %HealthListResponse{statuses: [:SERVING]}
    end)
    |> Stream.run()
  end

  @spec watch(HealthCheckRequest.t(), GRPC.Server.Stream.t()) :: any()
  def watch(request, stream) do
    Stream.from(request)
    |> Stream.map(fn _ ->
      %HealthCheckResponse{status: :SERVING}
    end)
    |> Stream.run_with(stream)
  end
end
