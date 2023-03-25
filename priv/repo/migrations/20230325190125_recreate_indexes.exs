defmodule VxUnderground.Repo.Local.Migrations.RecreateIndexes do
  use Ecto.Migration

  def change do
    # drop_if_exists unique_index(:samples, :sha1)
    # drop_if_exists unique_index(:samples, :sha256)
    # drop_if_exists unique_index(:samples, :sha512)
    # drop_if_exists unique_index(:samples, :md5)

    # create unique_index(:samples, :sha1)
    # create unique_index(:samples, :sha256)
    # create unique_index(:samples, :sha512)
    # create unique_index(:samples, :md5)
  end
end
