defmodule VExchange.Repo.Local.Migrations.AddUserTier do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :tier, :string
      add :username, :string
    end
  end
end
