defmodule Scanner.Ethereum do
  @moduledoc false

  alias Scanner.Ethereum.Payment

  alias Scanner.Servers.CheckerSup

  alias Scanner.Spiders.{Crawler, Ethereum}

  alias Scanner.Repo

  @typep status :: :pending | :complete

  @doc """
  Given a tx_hash, it returns the status of the given transaction

  If the transaction does not exist in the db, it is stored added
  within the db.

  If the transaction is pending, it schedules a continous check that runs
  until it is confirmed

  ## Examples
    iex> transaction_status(tx_hash)
    {:ok, status}

  """
  @spec transaction_status(tx_hash :: String.t(), opts :: Keyword.t()) :: {:ok, status}
  def transaction_status(tx_hash, opts \\ [complete: false]) do
    with {:ok, payment} <- get_payment(tx_hash),
         {:ok, _res} = resp <- check_status(payment, opts),
         do: resp
  end

  defp get_payment(tx_hash) do
    case Repo.get_by(Payment, tx_hash: tx_hash) do
      %Payment{} = pay -> {:ok, pay}
      _ -> {:ok, create_new_payment(tx_hash)}
    end
  end

  defp create_new_payment(tx_hash) do
    attrs = %{"tx_hash" => tx_hash}

    attrs
    |> Payment.creation_changeset()
    |> Repo.insert!()
  end

  defp check_status(%Payment{status: status, tx_hash: tx_hash}, opts) do
    case status do
      :complete -> {:ok, status}
      :pending -> confirm_remote_status(tx_hash, opts)
    end
  end

  defp confirm_remote_status(tx_hash, opts, crawler \\ required_crawler()) do
    tx_hash
    |> crawler.scrap_transaction_page(opts)
    |> maybe_trigger_recheck()
  end

  defp maybe_trigger_recheck(%Ethereum{confirmed_blocks: blocks, tx_hash: tx_hash}) do
    cond do
      blocks >= required_blocks() ->
        {:ok, :complete}

      true ->
        CheckerSup.start_checker(tx_hash)
        {:ok, :pending}
    end
  end

  defp required_blocks do
    :scanner
    |> Application.get_env(:crawler)
    |> Keyword.get(:blocks, 2)
  end

  defp required_crawler do
    :scanner
    |> Application.get_env(:crawler)
    |> Keyword.get(:module, Crawler)
  end
end
