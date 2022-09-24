defmodule ScannerWeb.EthereumController.Fallback do
  @moduledoc false

  use Phoenix.Controller

  alias ScannerWeb.ErrorView

  @doc false
  def call(conn, {:error, :tx_not_found}) do
    conn
    |> put_status(400)
    |> put_view(ErrorView)
    |> render("400.json", %{error: "transaction with given hash does not exist"})
  end
end
