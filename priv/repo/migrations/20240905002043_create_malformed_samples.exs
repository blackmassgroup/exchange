defmodule Exchange.Repo.Migrations.CreateMalformedSamples do
  use Ecto.Migration

  def change do
    create table(:malformed_samples) do
      add :sha256, :string
      add :sample_id, references(:samples, on_delete: :nothing)

      timestamps()
    end

    create index(:malformed_samples, [:sample_id])
  end
end
