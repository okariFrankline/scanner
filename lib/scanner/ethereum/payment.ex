defmodule Scanner.Ethereum.Payment do
  @moduledoc """
  Represents a single ethereum payment
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset

  @typedoc """
  A single ethereum payment
  """
  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "payments" do
    field :tx_hash, :string
    field :status, Ecto.Enum, values: [:pending, :complete]

    timestamps()
  end

  @doc """
  Returns a changeset for inserting a new payment
  """
  @spec creation_changeset(payment :: t | Changeset.t(), attrs :: map) :: Changeset.t()
  def creation_changeset(payment \\ %__MODULE__{}, attrs) do
    payment
    |> cast(attrs, [:tx_hash, :status])
    |> validate_required([:tx_hash])
    |> add_default_status()
    |> unique_constraint(:tx_hash)
  end

  defp add_default_status(%Changeset{} = changeset) do
    put_change(changeset, :status, :pending)
  end

  @doc """
  Returns a changeset marking a payment as complete
  """
  @spec complete_changeset(payment :: t) :: Changeset.t()
  def complete_changeset(%__MODULE__{} = payment) do
    payment
    |> change()
    |> put_change(:status, :complete)
  end
end
