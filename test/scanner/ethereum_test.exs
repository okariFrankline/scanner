defmodule Scanner.EthereumTest do
  @moduledoc false

  use Scanner.DataCase, async: false

  alias Scanner.Ethereum

  alias Scanner.Ethereum.Payment

  alias Scanner.Spiders.Crawler

  alias Scanner.Servers.{Checker, CheckerSup}

  @moduletag :ethereum

  @real_tx_hash "0x26448b745d44c9da1ffc290212af5a01bb94bdf58af1a278691a5d1f650bec45"

  describe "transaction_status/1" do
    test "given a transaction that is already in the db and is complete, it returns complete status" do
      transaction = insert(:payment)

      transaction
      |> Changeset.change(%{status: :complete})
      |> Repo.update!()

      assert {:ok, :complete} = Ethereum.transaction_status(transaction.tx_hash)
    end

    test "given a transaction which has attained the required confirmed blocks and is not already stored in the db, it returns complete" do
      tx_hash = Ecto.UUID.generate()

      assert {:ok, :complete} = Ethereum.transaction_status(tx_hash, complete: true)

      assert %Payment{status: :complete} = Repo.get_by(Payment, tx_hash: tx_hash)
    end

    test "given a transaction that has not reached the confirmed blocks, it returns a pending status" do
      tx_hash = Ecto.UUID.generate()

      assert {:ok, :pending} = Ethereum.transaction_status(tx_hash, complete: false)

      assert %Payment{status: :pending} = Repo.get_by(Payment, tx_hash: tx_hash)

      on_exit(fn -> CheckerSup.stop_checker(tx_hash) end)
    end

    test "given a transaction that is incomplete, it ensures that the Checker process for that transaction is started to monitor the transaction" do
      tx_hash = Ecto.UUID.generate()

      Ethereum.transaction_status(tx_hash, complete: false)

      tx_process_name = Checker.name(tx_hash)
      tx_process_pid = Process.whereis(tx_process_name)

      refute is_nil(tx_process_pid)
      assert Process.alive?(tx_process_pid)
      assert [{_, ^tx_process_pid, _, _}] = DynamicSupervisor.which_children(CheckerSup)

      on_exit(fn -> CheckerSup.stop_checker(tx_hash) end)
    end
  end

  describe "transaction_status/1 integration test" do
    setup do
      Application.put_env(:scanner, :crawler, module: Crawler)

      :ok
    end

    @tag :integration
    test "given a transaction hash that exists and has attained the confirmation blocs, it returns a status of complete" do
      assert {:ok, :complete} = Ethereum.transaction_status(@real_tx_hash)

      from_db = Repo.get_by!(Payment, tx_hash: @real_tx_hash)

      refute is_nil(from_db)
      assert from_db.status == :complete
    end

    @tag :integration
    test "given a transaction hash that does not exist within the block chain, it returns a transaction not found error" do
      assert {:error, :tx_not_found} =
               Ethereum.transaction_status("non existent transaction hash")

      refute Repo.get_by(Payment, tx_hash: "non existent transaction hash")
    end
  end
end
