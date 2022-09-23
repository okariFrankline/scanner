defmodule Scanner.Repo do
  use Ecto.Repo,
    otp_app: :scanner,
    adapter: Ecto.Adapters.Postgres
end
