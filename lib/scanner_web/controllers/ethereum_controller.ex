defmodule ScannerWeb.EthereumController do
  @moduledoc false

  use ScannerWeb, :controller

  alias Scanner.Ethereum

  action_fallback __MODULE__.Fallback

  @doc """
  Returns the current status of a transaction identified
  by the transaction hash

  Params
    - tx_hash (required): the transaction hash

  """
  def transaction_status(conn, %{"tx_hash" => tx_hash}) do
    with {:ok, status} <- Ethereum.transaction_status(tx_hash) do
      conn
      |> put_status(200)
      |> render("status.json", status: status)
    end
  end
end
