defmodule Exchange.Repo.Local.Migrations.RecreateIndexSha256 do
  use Ecto.Migration

  def change do
    create unique_index(:samples, :sha512)
  end
end
