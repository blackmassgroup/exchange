defmodule Exchange.Repo.Local.Migrations.RemoveMalcoreApiKeyFromUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :malcore_api_key
    end
  end
end
