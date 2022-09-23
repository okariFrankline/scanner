defmodule Scanner.Repo.Migrations.CreatePayment do
  use Ecto.Migration

  def change do
    create table(:payments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :tx_hash, :string, null: false
      add :status, :string, default: "pending"

      timestamps()
    end

    create unique_index(:payments, [:tx_hash])
  end
end
