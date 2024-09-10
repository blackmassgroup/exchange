defmodule Exchange.Repo.Local.Migrations.Remove do
  use Ecto.Migration

  def change do
    drop unique_index(:samples, :sha1)
    drop unique_index(:samples, :sha256)
    drop unique_index(:samples, :sha512)
    drop unique_index(:samples, :md5)
  end
end
