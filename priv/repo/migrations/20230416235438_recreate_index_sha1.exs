defmodule VExchange.Repo.Local.Migrations.RecreateIndexSha1 do
  use Ecto.Migration

  def change do
    create unique_index(:samples, :sha256)
  end
end
