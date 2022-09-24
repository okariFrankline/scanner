defmodule Scanner.Servers.CheckerSup do
  @moduledoc """
  This is dynamic supervisor that will start all the ethereum payment
  checkers
  """

  use DynamicSupervisor

  alias Scanner.Servers.Checker

  alias Scanner.Spiders.Crawler

  require Logger

  @doc false
  @spec start_link(opts :: Keyword.t()) :: Supervisor.on_start()
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Starts a new checker process registered under the name of the provided
  transaction hash
  """
  @spec start_checker(tx_hash :: String.t()) :: DynamicSupervisor.on_start_child()
  def start_checker(tx_hash) do
    spec = checker_child_spec(tx_hash)

    Logger.info("Starting checker process")

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @doc """
  Stops a given checker process

  Used mainly in testeing
  """
  @spec stop_checker(tx_hash :: String.t()) :: :ok
  def stop_checker(tx_hash) do
    if pid = child_pid(tx_hash) do
      DynamicSupervisor.terminate_child(__MODULE__, pid)
    end

    :ok
  end

  @impl DynamicSupervisor
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp checker_child_spec(tx_hash) do
    %{
      type: :worker,
      shutdown: 5000,
      restart: :transient,
      id: Checker.name(tx_hash),
      start: {Checker, :start_link, [[tx_hash: tx_hash, crawler: required_crawler()]]}
    }
  end

  defp required_crawler do
    :scanner
    |> Application.get_env(:crawler)
    |> Keyword.get(:module, Crawler)
  end

  defp child_pid(tx_hash) do
    tx_hash
    |> Checker.name()
    |> Process.whereis()
  end
end
