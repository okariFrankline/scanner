# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :scanner,
  ecto_repos: [Scanner.Repo]

# Configures the endpoint
config :scanner, ScannerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ScannerWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Scanner.PubSub,
  live_view: [signing_salt: "18hv50X9"]

# crawly
config :crawly,
  middlewares: [
    {Crawly.Middlewares.UserAgent,
     user_agents: [
       "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
     ]}
  ],
  pipelines: [
    Scanner.Spiders.EctoStorage
  ]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :scanner, Scanner.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :scanner,
  crawler: [
    blocks: 2,
    module: Scanner.Spiders.Crawler
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
