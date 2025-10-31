defmodule BasicGrpcService.Server do
  @moduledoc "Basic gRPC server"

  use GRPC.Server, service: Basic.V1.BasicService.Service

  require Logger

  # alias Basic.Service.V1.BackgroundResponse
  alias Basic.Service.V1.BackgroundResponse
  alias Basic.Service.V1.BackgroundResponseEvent
  alias BasicGrpcService.Utils

  alias Basic.Service.V1.{
    HelloRequest,
    HelloResponse,
    HelloResponseEvent,
    TalkRequest,
    TalkResponse,
    BackgroundRequest
  }

  @spec hello(HelloRequest.t(), GRPC.Server.Stream.t()) :: any()
  def hello(request, stream) do
    GRPC.Stream.unary(request)
    |> GRPC.Stream.map(fn %HelloRequest{message: message} ->
      payload = HelloResponseEvent.encode(%HelloResponseEvent{greeting: "Hello, #{message}!"})

      any = %Google.Protobuf.Any{
        type_url: "type.googleapis.com/basic.v1.BasicService.HelloResponseEvent",
        value: payload
      }

      %HelloResponse{
        cloud_event: Utils.create_cloudevent(any, stream)
      }
    end)
    |> GRPC.Stream.run()
  end

  @spec talk(Enumerable.t(), GRPC.Server.Stream.t()) :: any()
  def talk(request, stream) do
    GRPC.Stream.from(request)
    |> GRPC.Stream.map(fn %TalkRequest{message: message} ->
      {answer, _} = Eliza.talk(message)
      %TalkResponse{answer: answer}
    end)
    |> GRPC.Stream.run_with(stream)
  end

  @spec background(BackgroundRequest.t(), GRPC.Server.Stream.t()) :: any()
  def background(request, stream) do
    GRPC.Stream.unary(request)
    |> GRPC.Stream.map(fn %BackgroundRequest{processes: processes} ->
      # initialize state agent
      {:ok, state_agent} = Utils.State.Management.start()
      # create state unifier
      hash = UUID.uuid4()

      # Initialize state
      Utils.State.Management.update_state(
        state_agent,
        hash,
        %BackgroundResponseEvent{
          state: :STATE_PROCESS,
          started_at: Google.Protobuf.from_datetime(DateTime.utc_now()),
          completed_at: nil,
          responses: []
        }
      )

      {state_agent, hash, processes}
    end)
    |> GRPC.Stream.map(fn {state_agent, hash, processes} ->
      tasks =
        1..processes
        |> Enum.map(fn pid ->
          Task.async(fn ->
            Utils.dummy_service_call(pid)
          end)
        end)

      {state_agent, hash, tasks}
    end)
    |> GRPC.Stream.map(fn {state_agent, hash, tasks} ->
      initial_event = Utils.State.Management.get_state(state_agent, hash)

      tasks
      |> Enum.map(fn task ->
        Task.await(task)
      end)
      |> Enum.map(fn response ->
        event = %BackgroundResponseEvent{
          state: :STATE_PROCESS,
          started_at: initial_event.started_at,
          completed_at: nil,
          responses: [response]
        }

        Utils.State.Management.update_state(state_agent, hash, event)
      end)

      {state_agent, hash}
    end)
    |> GRPC.Stream.map(fn {state_agent, hash} ->
      event = Utils.State.Management.get_state(state_agent, hash)
      payload = BackgroundResponseEvent.encode(event)

      any = %Google.Protobuf.Any{
        type_url: "type.googleapis.com/basic.v1.BasicService.BackgroundResponseEvent",
        value: payload
      }

      cloud_event = Utils.create_cloudevent(any, stream)
      %BackgroundResponse{cloud_event: cloud_event}
    end)
    |> GRPC.Stream.run_with(stream)
  end
end
