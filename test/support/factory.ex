defmodule Scanner.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Scanner.Repo

  alias Scanner.Ethereum.Payment

  @doc """
  Returns an ethereum payment
  """
  def payment_factory do
    %Payment{
      tx_hash: Ecto.UUID.generate(),
      status: "pending"
    }
  end
end
