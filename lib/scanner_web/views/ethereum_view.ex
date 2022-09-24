defmodule ScannerWeb.EthereumView do
  @moduledoc false

  use ScannerWeb, :view

  @doc false
  def render("status.json", %{status: status}) do
    %{
      status: status
    }
  end
end
