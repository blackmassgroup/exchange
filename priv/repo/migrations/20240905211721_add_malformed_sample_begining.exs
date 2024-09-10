defmodule Exchange.Repo.Local.Migrations.AddMalformedSampleBegining do
  use Ecto.Migration

  def change do
    alter table(:malformed_samples) do
      add :beginning, :text
    end
  end
end
