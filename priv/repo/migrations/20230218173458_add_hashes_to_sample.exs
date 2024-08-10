defmodule VExchange.Repo.Migrations.AddHashesToSample do
  use Ecto.Migration

  def change do
    alter table(:samples) do
      remove :hash, :string
      add :md5, :string, size: 32
      add :sha1, :string, size: 40
      add :sha256, :string, size: 64
      add :sha512, :string, size: 128
      add :names, {:array, :string}
    end
  end
end
