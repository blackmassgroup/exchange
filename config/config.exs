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
    Oban.Plugins.Pruner,
    {Oban.Plugins.Lifeline, rescue_after: :timer.minutes(10)},
    Oban.Plugins.Reindexer,
    {Oban.Plugins.Cron,
     crontab: [
       {"0 * * * *", Exchange.ObanJobs.Vt.ClearApiLogs}
     ]}
  ]

oban_queues = [
  default: 10,
  vxu_uploads: 1,
  file_uploads: 50,
  vt_api_uploads: [limit: 25, paused: false],
  vt_comments: [limit: 25, paused: false],
  clean_samples: [limit: 200, paused: true],
  rename_samples: [limit: 100, paused: false],
  rename_samples_scheduler: [limit: 1, paused: false]
]

config :exchange, Oban,
  repo: Exchange.Repo.Local,
  engine: Oban.Engines.Basic,
  queues: oban_queues,
  plugins: oban_plugins,
  shutdown_grace_period: :timer.seconds(60)

config :exchange, env: Mix.env()

config :exchange,
  ecto_repos: [Exchange.Repo.Local]

config :error_tracker,
  repo: Exchange.Repo.Local,
  otp_app: :exchange

config :exchange, Exchange.Repo.Local,
  priv: "priv/repo",
  timeout: :infinity

# Configures the endpoint
config :exchange, ExchangeWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: ExchangeWeb.ErrorHTML, json: ExchangeWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Exchange.PubSub,
  live_view: [signing_salt: "hnZZR7D2"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :exchange, Exchange.Mailer, adapter: Swoosh.Adapters.Local

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
