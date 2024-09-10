defmodule VExchange.Repo.Local.Migrations.DropMalformedSamplesTable do
  use Ecto.Migration

  def change do
    drop table(:malformed_samples)
  end
end
