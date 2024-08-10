defmodule VExchange.Repo.Local.Migrations.AdjustTags do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      modify :sample_id, :integer, from: references(:samples)
    end
  end
end
