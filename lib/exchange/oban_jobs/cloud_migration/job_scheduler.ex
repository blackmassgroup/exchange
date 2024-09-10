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

  import Ecto.Query

  def queue_all_files_for_vt() do
    Exchange.Repo.transaction(fn ->
      from("samples")
      |> order_by([s], desc: s.inserted_at)
      |> select([s], s.sha256)
      |> Exchange.Repo.stream(max_rows: 10_000)
      |> Stream.chunk_every(1000)
      |> Stream.each(fn chunk ->
        Enum.map(chunk, fn sha256 ->
          %{
            "sha256" => sha256,
            "is_new" => false,
            "is_first_request" => true
          }
          |> Exchange.ObanJobs.Vt.SubmitVt.new()
        end)
        |> Oban.insert_all()
      end)
      |> Stream.run()
    end)
  end
end
