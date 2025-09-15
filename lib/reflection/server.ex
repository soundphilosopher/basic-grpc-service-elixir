defmodule BasicGrpcService.Reflection.Alpha.Server do
  @moduledoc "gRPC reflection server v1alpha"

  use GrpcReflection.Server,
    version: :v1alpha,
    services: [
      Basic.V1.BasicService.Service
    ]
end

defmodule BasicGrpcService.Reflection.Server do
  @moduledoc "gRPC reflection server v1"

  use GrpcReflection.Server,
    version: :v1,
    services: [
      Basic.V1.BasicService.Service
    ]
end
