defmodule Exchange.Repo.Local.Migrations.AddUniqueIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:samples, :sha1)
    create unique_index(:samples, :sha256)
    create unique_index(:samples, :sha512)
    create unique_index(:samples, :md5)
  end
end
