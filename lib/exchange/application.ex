defmodule Exchange.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    if Code.ensure_loaded?(Ecto.DevLogger) do
      Ecto.DevLogger.install(Exchange.Repo.Local)
    end

    children = [
      # Start the Telemetry supervisor
      ExchangeWeb.Telemetry,
      # Start the RPC server
      {Fly.RPC, []},
      # Start the Ecto repository
      Exchange.Repo.Local,
      # Start the supervisor for LSN tracking
      {Fly.Postgres.LSN.Supervisor, repo: Exchange.Repo.Local},
      # Start the PubSub system
      {Phoenix.PubSub, name: Exchange.PubSub},
      # Start Finch
      {Finch, name: Exchange.Finch},
      # Start the Endpoint (http/https)
      ExchangeWeb.Endpoint,
      # Start a worker by calling: Exchange.Worker.start_link(arg)
      # {Exchange.Worker, arg}
      {Cluster.Supervisor, [topologies, [name: Exchange.ClusterSupervisor]]},
      {Oban, Application.fetch_env!(:exchange, Oban)},
      # Start the vt rate limiter with initial limit
      {Exchange.VtApi.VtApiRateLimiter, Application.get_env(:exchange, :vt_api_rate_limit, 1500)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exchange.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExchangeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
