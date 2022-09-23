defmodule Scanner.Servers.CheckerSup do
  @moduledoc """
  This is dynamic supervisor that will start all the ethereum payment
  checkers
  """

  use DynamicSupervisor

  alias Scanner.Servers.Checker

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

    DynamicSupervisor.start_child(__MODULE__, spec)
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
      start: {Checker, :start_link, [tx_hash: tx_hash]}
    }
  end
end
