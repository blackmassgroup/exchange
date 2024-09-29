defmodule Exchange.ObanJobs.CloudMigration.SampleRename do
  use Oban.Worker, queue: :rename_samples, max_attempts: 20, unique: [period: :infinity]

  alias Exchange.Repo.Local, as: Repo
  alias Exchange.Sample
  alias Exchange.Services.VirusTotal
  alias Exchange.Services.S3
  alias Exchange.VtApi.VtApiRateLimiter

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"sha256" => sha256}}) do
    with {:ok, sample} <- get_sample(sha256),
         :ok <- VtApiRateLimiter.allow_request(0),
         {:ok, %{"attributes" => attrs}} <- VirusTotal.get_sample(sha256),
         {:ok, _} <- S3.copy_file_to_daily_backups(sha256, sample.inserted_at, attrs) do
      :ok
    else
      {:error, :does_not_exist} ->
        # Logger.error("Error processing sample #{sha256}: #{inspect(error)}")
        :ok

      _error ->
        # Logger.error("Error processing sample #{sha256}: #{inspect(error)}")
        snooze_time = VtApiRateLimiter.get_snooze_time(0)
        # Logger.warning("Snoozing job for #{sha256} because of VT rate limiting: #{snooze_time}")
        {:snooze, snooze_time}
    end
  end

  defp get_sample(sha256) do
    case Repo.get_by(Sample, sha256: sha256) do
      nil -> {:error, :sample_not_found}
      sample -> {:ok, sample}
    end
  end
end
