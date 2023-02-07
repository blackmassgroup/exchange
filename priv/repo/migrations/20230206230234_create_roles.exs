defmodule VxUnderground.Repo.Migrations.CreateRoles do
  use Ecto.Migration
  alias VxUnderground.Accounts

  def up do
    create table(:roles) do
      add :name, :string
      add :permissions, :map

      timestamps()
    end

    Enum.map(Accounts.DefaultRoles.all(), &Accounts.create_role(&1))
  end

  def down do
    drop table(:roles)
  end
end
