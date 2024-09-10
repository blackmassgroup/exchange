defmodule Exchange.Repo.Migrations.CreateCleanHashes do
  use Ecto.Migration

  def change do
    create table(:clean_hashes) do
      add :sha256, :string

      timestamps()
    end
  end
end
