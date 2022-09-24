defmodule ScannerWeb.EthereumController.Fallback do
  @moduledoc false

  use Phoenix.Controller

  alias ScannerWeb.ErrorView

  @doc false
  def call(conn, {:error, reason}) do
    conn
    |> put_status(400)
    |> put_view(ErrorView)
    |> render("400.json", %{error: reason})
  end
end
