defmodule Exchange.Repo.Local.Migrations.AddSamplesIndexes do
  use Ecto.Migration

  def up do
    # Add index on inserted_at
    execute("CREATE INDEX idx_samples_inserted_at ON samples (inserted_at)")

    # Add composite index
    execute(
      "CREATE INDEX idx_samples_inserted_at_composite ON samples (inserted_at, id, user_id)"
    )

    # Add descending index for inserted_at
    execute("CREATE INDEX idx_samples_inserted_at_desc ON samples (inserted_at DESC)")

    # Instead of a partial index, we'll create a regular index
    # You can filter recent data in your queries
    execute("CREATE INDEX idx_samples_inserted_at_id ON samples (inserted_at, id)")

    # Analyze the table to update statistics
    execute("ANALYZE samples")
  end

  def down do
    # Remove the indexes in reverse order
    execute("DROP INDEX IF EXISTS idx_samples_inserted_at_id")
    execute("DROP INDEX IF EXISTS idx_samples_inserted_at_desc")
    execute("DROP INDEX IF EXISTS idx_samples_inserted_at_composite")
    execute("DROP INDEX IF EXISTS idx_samples_inserted_at")
  end
end
