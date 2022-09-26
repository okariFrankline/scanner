defmodule ScannerWeb.EthereumControllerTest do
  @moduledoc false

  use ScannerWeb.ConnCase

  alias Scanner.Servers.CheckerSup

  alias Scanner.Spiders.{Crawler, CrawlerMock}

  @moduletag :ethereum_controller

  @real_tx_hash "0x26448b745d44c9da1ffc290212af5a01bb94bdf58af1a278691a5d1f650bec45"

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

  describe "GET /api/transaction/status integration test" do
    setup do
      Application.put_env(:scanner, :crawler, module: Crawler)

      on_exit(fn -> Application.put_env(:scanner, :crawler, module: CrawlerMock) end)

      :ok
    end

    @tag :integration
    test "given a transaction that exists, it returns the current status of the transaction", %{
      conn: conn
    } do
      assert %{"status" => "complete"} =
               conn
               |> get(Routes.ethereum_path(conn, :transaction_status), %{
                 "tx_hash" => @real_tx_hash
               })
               |> json_response(200)
    end

    @tag :integration
    test "given a transaction hash that does not eixist on chain, it returns a 400 error and a helpful message",
         %{conn: conn} do
      assert %{"error" => "transaction with given hash does not exist"} =
               conn
               |> get(Routes.ethereum_path(conn, :transaction_status), %{
                 "tx_hash" => "non existent tx_hash"
               })
               |> json_response(400)
    end
  end
end
