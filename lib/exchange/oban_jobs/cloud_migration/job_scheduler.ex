defmodule Exchange.ObanJobs.CloudMigration.JobScheduler do
  @moduledoc """
  Used to do daily backups for easy archive.

  Usage:
  ```

  Exchange.ObanJobs.CloudMigration.JobScheduler.insert_daily_uploader_jobs(~D[2024-08-01], ~D[2024-08-01])
  Exchange.ObanJobs.CloudMigration.JobScheduler.insert_daily_uploader_jobs(~D[2024-08-01])
  ```
  """
  alias Exchange.ObanJobs.CloudMigration.DailyUploader
  require Logger

  def insert_daily_uploader_jobs(start_date, end_date) do
    insert_jobs(start_date, end_date)
  end

  def insert_daily_uploader_jobs(start_date) do
    end_date = Date.utc_today()

    insert_jobs(start_date, end_date)
  end

  defp insert_jobs(start_date, end_date) do
    Enum.each(Date.range(start_date, end_date), fn date ->
      args = %{"date" => Date.to_iso8601(date)}

      DailyUploader.new(args)
      |> Oban.insert!()

      Logger.info("Inserted DailyUploader job for date: #{date}")
    end)
  end

  defmodule Test do
    import Ecto.Query

    def queue_all_files_for_vt() do
      # Adjust this value based on your system's capacity
      batch_size = 100
      # Delay between batches in milliseconds
      delay_ms = 1000

      Stream.resource(
        fn -> 0 end,
        fn offset ->
          query =
            from(s in "samples",
              order_by: [desc: s.inserted_at],
              select: s.sha256,
              limit: ^batch_size,
              offset: ^offset
            )

          case Exchange.Repo.all(query) do
            [] ->
              {:halt, offset}

            batch ->
              jobs =
                Enum.map(batch, fn sha256 ->
                  %{
                    "sha256" => sha256,
                    "is_new" => false,
                    "is_first_request" => true
                  }
                  |> Exchange.ObanJobs.Vt.SubmitVt.new()
                end)

              Oban.insert_all(jobs)

              # Add delay between batches
              Process.sleep(delay_ms)
              {[length(batch)], offset + batch_size}
          end
        end,
        fn _offset -> :ok end
      )
      |> Stream.run()
    end
  end
end
