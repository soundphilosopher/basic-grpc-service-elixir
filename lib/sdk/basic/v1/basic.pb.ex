defmodule Basic.V1.BasicService.Service do
  @moduledoc false

  use GRPC.Service, name: "basic.v1.BasicService", protoc_gen_elixir_version: "0.15.0"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "BasicService",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "Hello",
          input_type: ".basic.service.v1.HelloRequest",
          output_type: ".basic.service.v1.HelloResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: []
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: []
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "Talk",
          input_type: ".basic.service.v1.TalkRequest",
          output_type: ".basic.service.v1.TalkResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: []
          },
          client_streaming: true,
          server_streaming: true,
          __unknown_fields__: []
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "Background",
          input_type: ".basic.service.v1.BackgroundRequest",
          output_type: ".basic.service.v1.BackgroundResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: []
          },
          client_streaming: false,
          server_streaming: true,
          __unknown_fields__: []
        }
      ],
      options: nil,
      __unknown_fields__: []
    }
  end

  rpc :Hello, Basic.Service.V1.HelloRequest, Basic.Service.V1.HelloResponse

  rpc :Talk, stream(Basic.Service.V1.TalkRequest), stream(Basic.Service.V1.TalkResponse)

  rpc :Background, Basic.Service.V1.BackgroundRequest, stream(Basic.Service.V1.BackgroundResponse)
end

defmodule Basic.V1.BasicService.Stub do
  @moduledoc false

  use GRPC.Stub, service: Basic.V1.BasicService.Service
end
