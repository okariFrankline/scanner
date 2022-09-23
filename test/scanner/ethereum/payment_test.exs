defmodule Scanner.Ethereum.PaymentTest do
  @moduledoc false

  use Scanner.DataCase, async: true

  alias Scanner.Ethereum.Payment

  @moduletag :ethereum_payment

  describe "creation_changeset/2" do
    test "given all the required attrs, it returns a valid payment changeset" do
      params = string_params_for(:payment)

      assert %Changeset{valid?: true} = Payment.creation_changeset(params)
    end

    test "given params missing the required tx_hash attribute, it should return an invalid changeset" do
      params =
        :payment
        |> string_params_for()
        |> Map.drop(["tx_hash"])

      assert %Changeset{valid?: false} = Payment.creation_changeset(params)
    end
  end

  describe "complete_changeset/1" do
    test "given a valid payment that is pending, it should return a valid changeset" do
      payment =
        :payment
        |> string_params_for()
        |> Payment.creation_changeset()
        |> Repo.insert!()

      assert %Changeset{valid?: true, changes: %{status: :complete}} =
               Payment.complete_changeset(payment)
    end
  end
end
