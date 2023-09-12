defmodule VxUndergroundWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :vx_underground

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_vx_underground_key",
    signing_salt: "z/58Ffx2",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :vx_underground,
    gzip: false,
    only: VxUndergroundWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :vx_underground
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library(),
    body_reader: {VxUndergroundWeb.ApiBodyReader, :read_body, []}

  # if Application.compile_env(:vx_underground, :env) not in [:test, :dev] do
  #   plug VxUndergroundWeb.Plugs.CloudflareIpValidator
  # end

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug RemoteIp, headers: ~w[cf-connecting-ip]
  plug Paraxial.AllowedPlug
  plug Paraxial.RecordPlug
  plug VxUndergroundWeb.Router
  plug Paraxial.RecordPlug
end
