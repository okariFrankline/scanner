defmodule Scanner.Spiders.EctoStorage do
  @moduledoc """
  This is the Scanner.Spiders.Ethereum pipeline parser that is responsible for
  updating the payments' statuses represented by the tx_hash
  """

  alias Scanner.Spiders.Ethereum

  alias Scanner.Ethereum.Payment

  alias Scanner.Repo

  @doc """
  Based on the number of confirmed blocks, it either updates the
  payment to complete or leaves it as pending

  If either the tx_hash or the confirmed blocks is an empty list,
  it means crawly the tx page with the provided tx_hash resulted in
  the transaction not exisiting, hence, nothing happens
  """
  @spec run(eth :: Ethereum.t(), state) :: {Ethereum.t(), state} | {false, state}
        when state: term
  def run(%Ethereum{confirmed_blocks: [], tx_hash: []}, state), do: {false, state}

  def run(%Ethereum{confirmed_blocks: blocks} = item, state) do
    if blocks >= required_blocks() do
      mark_payment_as_complete(item, state)
    else
      {false, state}
    end
  end

  defp mark_payment_as_complete(%Ethereum{tx_hash: tx_hash} = item, state) do
    Payment
    |> Repo.get_by!(tx_hash: tx_hash)
    |> Payment.complete_changeset()
    |> do_update_payment(item, state)
  end

  defp do_update_payment(changeset, item, state) do
    case Repo.update(changeset) do
      {:error, _} -> {false, state}
      {:ok, _} -> {item, state}
    end
  end

  defp required_blocks do
    :scanner
    |> Application.get_env(:crawler)
    |> Keyword.get(:blocks, 2)
  end
end
