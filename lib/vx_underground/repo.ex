defmodule VxUnderground.Repo do
  use Ecto.Repo,
    otp_app: :vx_underground,
    adapter: Ecto.Adapters.Postgres
end
