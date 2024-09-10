defmodule Exchange.Repo.Local.Migrations.Sha1Index do
  use Ecto.Migration

  def change do
    drop_if_exists unique_index(:samples, :sha1)
    create unique_index(:samples, :sha1)
  end
end
