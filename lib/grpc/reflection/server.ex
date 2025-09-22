defmodule Reflection.V1.Server do
  use GrpcReflection.Server,
    version: :v1,
    services: [Basic.V1.BasicService.Service, Grpc.Health.V1.Health.Service]
end

defmodule Reflection.V1alpha.Server do
  use GrpcReflection.Server,
    version: :v1alpha,
    services: [Basic.V1.BasicService.Service, Grpc.Health.V1.Health.Service]
end
