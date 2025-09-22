defmodule BasicGrpcService.Endpoint do
  @moduledoc "Basic gRPC server endpoint"

  use GRPC.Endpoint

  intercept(GRPC.Server.Interceptors.Logger)

  run(BasicGrpcService.Server)
  run(Health.Server)
  run(Reflection.V1.Server)
  run(Reflection.V1alpha.Server)
end
