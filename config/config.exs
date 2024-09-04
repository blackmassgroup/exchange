# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

one_hour = 3600
pruner_max_age = one_hour

oban_plugins =
  [
    {Oban.Plugins.Pruner, max_age: pruner_max_age},
    Oban.Plugins.Lifeline,
    Oban.Plugins.Reindexer
  ]

oban_queues = [default: 10, vxu_uploads: 1, file_uploads: 50, vt_api: 150]

config :v_exchange, Oban,
  repo: VExchange.Repo.Local,
  engine: Oban.Engines.Basic,
  queues: oban_queues,
  plugins: oban_plugins,
  shutdown_grace_period: :timer.seconds(60)

config :v_exchange, env: Mix.env()

config :v_exchange,
  ecto_repos: [VExchange.Repo.Local]

config :error_tracker,
  repo: VExchange.Repo.Local,
  otp_app: :v_exchange

config :v_exchange, VExchange.Repo.Local,
  priv: "priv/repo",
  timeout: :infinity

# Configures the endpoint
config :v_exchange, VExchangeWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: VExchangeWeb.ErrorHTML, json: VExchangeWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: VExchange.PubSub,
  live_view: [signing_salt: "hnZZR7D2"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :v_exchange, VExchange.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tesla, :adapter, Tesla.Adapter.Hackney

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
