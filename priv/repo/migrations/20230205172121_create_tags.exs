defmodule VExchange.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string
      add :kind, :string

      timestamps()
    end
  end
end
