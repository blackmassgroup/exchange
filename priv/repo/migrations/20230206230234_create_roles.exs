defmodule VxUnderground.Repo.Migrations.CreateRoles do
  use Ecto.Migration
  alias VxUnderground.Accounts

  def change do
    create table(:roles) do
      add :name, :string
      add :permissions, :map

      timestamps()
    end
  end
end
