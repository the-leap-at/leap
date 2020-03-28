defmodule Leap.Repo do
  use Ecto.Repo,
    otp_app: :leap,
    adapter: Ecto.Adapters.Postgres
end
