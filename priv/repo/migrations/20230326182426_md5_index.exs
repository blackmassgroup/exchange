defmodule Exchange.Repo.Local.Migrations.Md5Index do
  use Ecto.Migration

  def change do
    drop_if_exists unique_index(:samples, :md5)
    create unique_index(:samples, :md5)
  end
end
