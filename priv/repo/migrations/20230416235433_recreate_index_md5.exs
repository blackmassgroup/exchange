defmodule VExchange.Repo.Local.Migrations.RecreateIndexMd5 do
  use Ecto.Migration

  def change do
    create unique_index(:samples, :sha1)
  end
end
