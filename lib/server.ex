defmodule BasicGrpcService.Server do
  @moduledoc "Basic gRPC server"

  use GRPC.Server, service: Basic.V1.BasicService.Service, http_transcode: true

  alias Eliza
  alias GRPC.Stream

  alias Basic.Service.V1.{
    HelloRequest,
    HelloResponse,
    HelloResponseEvent,
    TalkRequest,
    TalkResponse
  }

  alias Io.Cloudevents.V1.CloudEvent

  @spec hello(HelloRequest.t(), GRPC.Server.Stream.t()) :: any()
  def hello(request, _stream) do
    Stream.unary(request)
    |> Stream.map(fn %HelloRequest{message: message} ->
      greeting = "Hello, #{message}!"

      response_event = %HelloResponseEvent{
        greeting: greeting
      }

      event_data = HelloResponseEvent.encode(response_event)

      cloud_event = %CloudEvent{
        id: :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower),
        spec_version: "1.0",
        source: "",
        type: "",
        data: event_data
      }

      %HelloResponse{
        cloud_event: cloud_event
      }
    end)
    |> GRPC.Stream.run()
  end

  @spec talk(Enumerable.t(), GRPC.Server.Stream.t()) :: any()
  def talk(request, stream) do
    Stream.from(request, max_demand: 10)
    |> Stream.map(fn %TalkRequest{message: message} ->
      {answer, _} = Eliza.talk(message)
      %TalkResponse{answer: answer}
    end)
    |> Stream.run_with(stream)
  end

  @spec background(Enumerable.t(), GRPC.Server.Stream.t()) :: any()
  def background(_request, _stream) do
  end
end
