defmodule BasicGrpcService.Endpoint do
  @moduledoc "Basic gRPC server endpoint"

  use GRPC.Endpoint

  intercept(GRPC.Server.Interceptors.Logger)

  run(BasicGrpcService.Server)
  run(BasicGrpcService.Reflection.Alpha.Server)
  run(BasicGrpcService.Reflection.Server)
end
