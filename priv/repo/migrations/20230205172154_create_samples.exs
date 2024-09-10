defmodule Exchange.Repo.Migrations.CreateSamples do
  use Ecto.Migration

  def change do
    create table(:samples) do
      add :hash, :string
      add :size, :integer
      add :type, :string
      add :first_seen, :utc_datetime
      add :s3_object_key, :string
      add :tags, {:array, :integer}

      timestamps()
    end
  end
end
