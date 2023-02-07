defmodule VxUnderground.Repo.Migrations.AddRolesToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role_id, references(:roles, on_delete: :nothing)
      add :custom_permissions, :map
    end
  end
end
