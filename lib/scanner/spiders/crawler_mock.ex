defmodule Scanner.Spiders.CrawlerMock do
  @moduledoc """
  This module is a mock of the actual crawler and will be used
  mostly during testing

  """

  alias Scanner.Spiders.Ethereum

  alias Scanner.Ethereum.Payment

  alias Scanner.Repo

  @doc """
  Returns mock data for scrapping a transaction page for a given transaction hash

  Based on the value of the transaction payment status, it either returns a complete
  or pending ethereum item
  """
  @spec scrap_transaction_page(tx_hash :: String.t(), opts :: Keyword.t()) :: Ethereum.t()
  def scrap_transaction_page(tx_hash, opts \\ [complete: true]) do
    with {:ok, blocks} <- {:ok, required_blocks()},
         {:ok, payment} <- {:ok, get_transaction!(tx_hash)},
         do: create_ethereum(payment, blocks, opts)
  end

  defp required_blocks do
    :scanner
    |> Application.get_env(:crawler)
    |> Keyword.get(:blocks, 2)
  end

  defp get_transaction!(tx_hash) do
    Repo.get_by!(Payment, tx_hash: tx_hash)
  end

  defp create_ethereum(payment, blocks, opts) do
    if opts[:complete] do
      complete_payment_and_return_eth(payment, blocks)
    else
      new_ethereum(payment.tx_hash, blocks - 1)
    end
  end

  defp complete_payment_and_return_eth(payment, blocks) do
    payment
    |> Ecto.Changeset.change(%{status: :complete})
    |> Repo.update!()
    |> then(&new_ethereum(&1.tx_hash, blocks))
  end

  defp new_ethereum(tx_hash, blocks) do
    %Ethereum{tx_hash: tx_hash, confirmed_blocks: blocks}
  end
end
