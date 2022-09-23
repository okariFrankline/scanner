defmodule Scanner.Servers.Checker do
  @moduledoc """
  This module is a GenServer that is responsible for checking
  whether or not the given transaction has been reached the
  required confirmation blocks or not.

  If it has, it marks the transaction as complete and if not, it
  schedules itself to run in every five seconds to do a recheck
  """

  use GenServer, shutdown: 5000, restart: :transient

  alias Crawly.ParsedItem

  alias Scanner.Spiders.Ethereum

  @recheck_every :timer.seconds(5)

  @etherscan_url "https://etherscan.io/tx"

  @doc """
  Starts the Process
  """
  @spec start_link(opts :: Keyword.t()) :: GenServer.on_start()
  def start_link(opts) do
    name = Keyword.fetch!(opts, :tx_hash)

    GenServer.start_link(__MODULE__, opts, name: name(name))
  end

  @doc """
  Returns the name of the process as an atom, given a string
  """
  @spec name(name :: String.t()) :: atom
  def name(name), do: String.to_atom(name)

  @impl GenServer
  def init(opts) do
    schedule_recheck()
    {:ok, %{tx_hash: opts[:tx_hash]}}
  end

  @impl GenServer
  def handle_info(:recheck, %{tx_hash: tx_hash} = state) do
    %Ethereum{confirmed_blocks: blocks} = scrap_transaction_page(tx_hash)

    cond do
      blocks >= 2 ->
        {:stop, :normal, state}

      true ->
        schedule_recheck()
        {:noreply, state}
    end
  end

  defp scrap_transaction_page(tx_hash) do
    url = "#{@etherscan_url}/#{tx_hash}"

    url
    |> Crawly.fetch(with: Ethereum)
    |> fetch_parsed_item()
  end

  defp fetch_parsed_item({_, %ParsedItem{items: [item]}, _, _}), do: item

  defp schedule_recheck do
    Process.send_after(self(), :recheck, @recheck_every)
  end
end
