defmodule VxUnderground.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      # Start the Telemetry supervisor
      VxUndergroundWeb.Telemetry,
      # Start the RPC server
      {Fly.RPC, []},
      # Start the Ecto repository
      VxUnderground.Repo.Local,
      # Start the supervisor for LSN tracking
      {Fly.Postgres.LSN.Supervisor, repo: VxUnderground.Repo.Local},
      # Start the PubSub system
      {Phoenix.PubSub, name: VxUnderground.PubSub},
      # Start Finch
      {Finch, name: VxUnderground.Finch},
      # Start the Endpoint (http/https)
      VxUndergroundWeb.Endpoint,
      # Start a worker by calling: VxUnderground.Worker.start_link(arg)
      # {VxUnderground.Worker, arg}
      {Cluster.Supervisor, [topologies, [name: VxUnderground.ClusterSupervisor]]},
      {Oban, Application.fetch_env!(:vx_underground, Oban)},
      VxUndergroundWeb.QueryCache,
      VxUnderground.Services.CloudflareEts
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VxUnderground.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VxUndergroundWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
