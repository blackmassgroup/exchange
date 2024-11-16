defmodule Exchange.Repo.Local.Migrations.RemoveVtApiRequestLog do
  use Ecto.Migration

  def change do
    drop table(:vt_api_requests)
  end
end
