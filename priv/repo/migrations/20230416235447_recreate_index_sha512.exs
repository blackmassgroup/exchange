defmodule VExchange.Repo.Local.Migrations.RecreateIndexSha512 do
  use Ecto.Migration

  def change do
    create unique_index(:samples, :md5)
  end
end
