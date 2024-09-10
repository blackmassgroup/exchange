defmodule Exchange.Repo.Local.Migrations.TagSetup do
  use Ecto.Migration

  def change do
    alter table(:samples) do
      remove :tags
    end

    alter table(:tags) do
      add :sample_id, references(:samples)
    end
  end
end
