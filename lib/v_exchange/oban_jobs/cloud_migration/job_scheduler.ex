defmodule VExchange.ObanJobs.CloudMigration.JobScheduler do
  @moduledoc """
  Used to do daily backups for easy archive.

  Usage:
  ```

  VExchange.ObanJobs.CloudMigration.JobScheduler.insert_daily_uploader_jobs(~D[2024-08-01], ~D[2024-08-01])
  VExchange.ObanJobs.CloudMigration.JobScheduler.insert_daily_uploader_jobs(~D[2024-08-01])
  ```
  """
  alias VExchange.ObanJobs.CloudMigration.DailyUploader
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
end
