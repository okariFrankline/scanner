defmodule ScannerWeb.EthereumControllerTest do
  @moduledoc false

  use ScannerWeb.ConnCase, async: true

  alias Scanner.Servers.CheckerSup

  @moduletag :ethereum_controller

  describe "GET /api/transaction/status" do
    test "given a transaction, it returns the status of the transation", %{conn: conn} do
      tx_hash = Ecto.UUID.generate()

      assert %{"status" => status} =
               conn
               |> get(Routes.ethereum_path(conn, :transaction_status), %{"tx_hash" => tx_hash})
               |> json_response(200)

      assert status in ["complete", "pending"]

      on_exit(fn -> CheckerSup.stop_checker(tx_hash) end)
    end
  end
end
