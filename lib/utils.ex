defmodule BasicGrpcService.Utils do
  @moduledoc "Basic service utilities"

  require Logger

  alias Basic.Service.V1.{
    SomeServiceResponse,
    SomeServiceData
  }

  alias Io.Cloudevents.V1.CloudEvent

  @spec create_cloudevent(Google.Protobuf.Any.t(), GRPC.Server.Stream.t()) ::
          CloudEvent.t()
  def create_cloudevent(payload, stream) do
    %CloudEvent{
      id: UUID.uuid4(),
      spec_version: "1.0",
      source: "#{stream.service_name}/#{stream.method_name}",
      type: "#{stream.response_mod}",
      data: {:proto_data, payload}
    }
  end

  @spec dummy_service_call(integer()) :: SomeServiceResponse.t()
  def dummy_service_call(process_id) do
    # Random delay between 1-3 seconds
    delay_ms = :rand.uniform(2000) + 1000
    Process.sleep(delay_ms)

    # Create dummy service response
    service_types = ["rest", "rpc", "grpc", "ws", "file", "graphql", "sql"]
    service_type = Enum.random(service_types)

    %SomeServiceResponse{
      id: UUID.uuid4(),
      name: "dummy-service-#{process_id}",
      version: "1.0.0",
      data: %SomeServiceData{
        value: "Result from process #{process_id} (#{service_type})",
        type: service_type
      }
    }
  end
end

defmodule BasicGrpcService.Utils.State.Management do
  @moduledoc "State management utilities"
  use Agent

  def start() do
    Agent.start_link(fn -> %{} end)
  end

  def get_state(agent, hash) do
    Agent.get(agent, &Map.get(&1, hash))
  end

  def update_state(agent, hash, state) do
    Agent.update(agent, &Map.put(&1, hash, state))
  end
end
