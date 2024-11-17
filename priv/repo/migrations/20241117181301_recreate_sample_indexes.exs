defmodule Exchange.Repo.Local.Migrations.RecreateSampleIndexes do
  use Ecto.Migration

  def up do
    # First drop all existing indexes
    drop_if_exists index(:samples, :md5)
    drop_if_exists index(:samples, :sha1)
    drop_if_exists index(:samples, :sha256)
    drop_if_exists index(:samples, :sha512)
    drop_if_exists index(:samples, :inserted_at)
    drop_if_exists index(:samples, [:inserted_at, :id])
    drop_if_exists index(:samples, [:inserted_at, :id, :user_id])
    execute("DROP INDEX IF EXISTS idx_samples_inserted_at")
    execute("DROP INDEX IF EXISTS idx_samples_inserted_at_id")
    execute("DROP INDEX IF EXISTS idx_samples_inserted_at_desc")
    execute("DROP INDEX IF EXISTS idx_samples_inserted_at_composite")

    # Recreate all indexes
    create unique_index(:samples, :md5)
    create unique_index(:samples, :sha1)
    create unique_index(:samples, :sha256)
    create unique_index(:samples, :sha512)

    # Recreate the performance indexes
    execute("CREATE INDEX idx_samples_inserted_at ON samples (inserted_at)")

    execute(
      "CREATE INDEX idx_samples_inserted_at_composite ON samples (inserted_at, id, user_id)"
    )

    execute("CREATE INDEX idx_samples_inserted_at_desc ON samples (inserted_at DESC)")
    execute("CREATE INDEX idx_samples_inserted_at_id ON samples (inserted_at, id)")

    # Update statistics
    execute("ANALYZE samples")
  end

  def down do
    # Drop all indexes
    drop_if_exists index(:samples, :md5)
    drop_if_exists index(:samples, :sha1)
    drop_if_exists index(:samples, :sha256)
    drop_if_exists index(:samples, :sha512)
    execute("DROP INDEX IF EXISTS idx_samples_inserted_at")
    execute("DROP INDEX IF EXISTS idx_samples_inserted_at_id")
    execute("DROP INDEX IF EXISTS idx_samples_inserted_at_desc")
    execute("DROP INDEX IF EXISTS idx_samples_inserted_at_composite")
  end
end
