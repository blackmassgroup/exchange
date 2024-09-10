defmodule Exchange.Repo.Local.Migrations.Import_Test do
  use Ecto.Migration

  def change do
    alter table(:samples) do
      modify :names, {:array, :text}
    end
  end
end
