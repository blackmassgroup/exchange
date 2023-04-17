defmodule VxUnderground.Repo.Local.Migrations.AddTagsBackToSamples do
  use Ecto.Migration

  def change do
    alter table(:samples) do
      add :tags, {:array, :text}
    end
  end
end
