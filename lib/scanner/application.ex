defmodule Scanner.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Scanner.Repo,
      # Start the Telemetry supervisor
      ScannerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Scanner.PubSub},
      # Start the Endpoint (http/https)
      ScannerWeb.Endpoint,
      # start checker supervisor
      {Scanner.Servers.CheckerSup, []}
      # Start a worker by calling: Scanner.Worker.start_link(arg)
      # {Scanner.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Scanner.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ScannerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
