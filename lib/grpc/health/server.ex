defmodule Health.Server do
  @moduledoc "gRPC health server"

  use GRPC.Server, service: Grpc.Health.V1.Health.Service

  require Logger

  alias GRPC.Stream

  alias Grpc.Health.V1.{
    HealthCheckRequest,
    HealthCheckResponse,
    HealthListRequest,
    HealthListResponse
  }

  @reflection_cfg {__MODULE__,
                   [
                     Basic.V1.BasicService.Service,
                     Grpc.Health.V1.Health.Service,
                     Grpc.Reflection.V1.ServerReflection.Service,
                     Grpc.Reflection.V1alpha.ServerReflection.Service
                   ]}

  @spec check(HealthCheckRequest.t(), GRPC.Server.Stream.t()) :: any()
  def check(request, _stream) do
    Stream.unary(request)
    |> Stream.map(fn %HealthCheckRequest{service: service} ->
      status = determine_service_status(service)
      %HealthCheckResponse{status: status}
    end)
    |> Stream.run()
  end

  @spec list(HealthListRequest.t(), GRPC.Server.Stream.t()) :: any()
  def list(request, _stream) do
    Stream.unary(request)
    |> Stream.map(fn _ ->
      try do
        services = GrpcReflection.Service.list_services(@reflection_cfg)

        # Create a map where keys are service names and values are HealthCheckResponse structs
        statuses =
          services
          |> Enum.map(fn service_name ->
            {service_name, %HealthCheckResponse{status: :SERVING}}
          end)
          |> Map.new()

        %HealthListResponse{statuses: statuses}
      rescue
        error ->
          Logger.warning("Failed to list services: #{inspect(error)}")
          %HealthListResponse{statuses: %{}}
      end
    end)
    |> Stream.run()
  end

  @spec watch(HealthCheckRequest.t(), GRPC.Server.Stream.t()) :: any()
  def watch(request, stream) do
    Stream.unary(request)
    |> Stream.map(fn %HealthCheckRequest{service: service} ->
      status = determine_service_status(service)
      %HealthCheckResponse{status: status}
    end)
    |> Stream.run_with(stream)
  end

  # Private helper function to determine the service status
  defp determine_service_status(service) when service in [nil, ""] do
    # If no service is specified, return UNKNOWN
    :NOT_SERVING
  end

  defp determine_service_status(service) do
    try do
      # Get the list of registered services from the reflection system
      registered_services = GrpcReflection.Service.list_services(@reflection_cfg)

      if service in registered_services do
        :SERVING
      else
        :SERVICE_UNKNOWN
      end
    rescue
      error ->
        Logger.warning("Failed to check service registration for '#{service}': #{inspect(error)}")
        # If we can't determine the service status, return UNKNOWN
        :NOT_SERVING
    end
  end
end
