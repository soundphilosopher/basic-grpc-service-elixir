defmodule BasicGrpcService.Application do
  use Application

  require Logger

  @cert_path Path.expand("./certs/local.crt", :code.priv_dir(:basic_grpc_service))
  @key_path Path.expand("./certs/local.key", :code.priv_dir(:basic_grpc_service))

  @impl true
  def start(_type, _args) do
    children = [
      # gRPC server using ONLY the servers configuration
      {GRPC.Server.Supervisor, start_args()},

      # gRPC reflection service
      GrpcReflection
    ]

    Logger.info("🚀 Starting BasicGrpcService")
    Logger.info("📡 HTTPS/HTTP2 server on port 9443 with TLS")

    opts = [strategy: :one_for_one, name: BasicGrpcService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp start_args do
    cred = GRPC.Credential.new(ssl: [certfile: @cert_path, keyfile: @key_path])

    opts = [
      endpoint: BasicGrpcService.Endpoint,
      port: 9443,
      start_server: true,
      adapter_opts: [cred: cred]
    ]

    opts
  end
end
