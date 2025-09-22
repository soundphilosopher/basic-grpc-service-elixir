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

    Logger.info("🚀 Starting BasicGrpcService on port 9443 with TLS")

    opts = [strategy: :one_for_one, name: BasicGrpcService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp start_args do
    # Check certificates exist
    case {File.exists?(@cert_path), File.exists?(@key_path)} do
      {true, true} ->
        Logger.info("✅ Found certificates, enabling TLS")
        Logger.info("   Cert: #{@cert_path}")
        Logger.info("   Key: #{@key_path}")

        [
          endpoint: BasicGrpcService.Endpoint,
          port: 9443,
          start_server: true,
          adapter_opts: [
            cred: GRPC.Credential.new(ssl: [certfile: @cert_path, keyfile: @key_path])
          ]
        ]

      {cert_exists, key_exists} ->
        Logger.warning("⚠️  Missing certificates (cert: #{cert_exists}, key: #{key_exists})")
        Logger.warning("   Starting without TLS")

        [
          endpoint: BasicGrpcService.Endpoint,
          port: 9443,
          start_server: true
        ]
    end
  end
end
