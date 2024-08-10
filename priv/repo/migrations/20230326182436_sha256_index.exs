defmodule VExchange.Repo.Local.Migrations.Sha256Index do
  use Ecto.Migration

  def change do
    drop_if_exists unique_index(:samples, :sha256)
    create unique_index(:samples, :sha256)
  end
end
