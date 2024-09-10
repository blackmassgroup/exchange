defmodule Exchange.Repo.Local.Migrations.AddUserIdToSamplesTable do
  use Ecto.Migration

  def change do
    alter table(:samples) do
      add :user_id, references(:users, on_delete: :nothing), null: true
    end
  end
end
