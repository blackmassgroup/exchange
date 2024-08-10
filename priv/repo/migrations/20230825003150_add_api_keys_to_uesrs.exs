defmodule VExchange.Repo.Local.Migrations.AddApiKeysToUesrs do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :api_key, :string
      add :malcore_api_key, :string
    end
  end
end
