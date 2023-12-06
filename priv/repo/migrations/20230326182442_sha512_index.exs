defmodule VExchange.Repo.Local.Migrations.Sha512Index do
  use Ecto.Migration

  def change do
    drop_if_exists unique_index(:samples, :sha512)
    create unique_index(:samples, :sha512)
  end
end
