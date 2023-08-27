# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :vx_underground, Oban,
  repo: VxUnderground.Repo.Local,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10]

config :vx_underground, env: Mix.env()

config :vx_underground,
  ecto_repos: [VxUnderground.Repo.Local]

config :vx_underground, VxUnderground.Repo.Local,
  priv: "priv/repo",
  timeout: :infinity

# Configures the endpoint
config :vx_underground, VxUndergroundWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: VxUndergroundWeb.ErrorHTML, json: VxUndergroundWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: VxUnderground.PubSub,
  live_view: [signing_salt: "hnZZR7D2"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :vx_underground, VxUnderground.Mailer, adapter: Swoosh.Adapters.Local

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

config :ex_aws,
  region: "us-east-1",
  s3: [
    scheme: "https://",
    host: "s3.us-east-1.wasabisys.com",
    region: "us-east-1"
  ]

config :vx_underground, s3_bucket_name: System.get_env("S3_BUCKET_NAME")

config :logger, :discord,
  level: :info,
  bot_token: System.get_env("DISCORD_BOT_TOKEN"),
  channel_id: System.get_env("DISCORD_CHANNEL_ID")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
