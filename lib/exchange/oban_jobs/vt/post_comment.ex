defmodule Exchange.ObanJobs.Vt.PostComment do
  @moduledoc """
  This module defines a worker for posting comments to VirusTotal.

  It is used to post comments to VirusTotal and update the Sample in the database accordingly.

  ## Usage

      To enqueue a job, you can use the `Oban.insert/2` function:
          %{
            "sha256" => sha256,
            "priority" => 0
          }
          |> Exchange.ObanJobs.Vt.PostComment.new()
          |> Oban.insert()
  """
  @max_attempts 20
  use Oban.Worker, queue: :vt_comments, max_attempts: @max_attempts
  require Logger

  alias Exchange.Services.VirusTotal
  alias Exchange.VtApi.VtApiRateLimiter
  alias Exchange.Samples

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"sha256" => sha256, "priority" => priority} = _args}) do
    with(
      :ok <- VtApiRateLimiter.allow_request(priority),
      comment <- Samples.get_comment(),
      {:ok, _} <- VirusTotal.post_file_comment(sha256, comment)
    ) do
      {:ok, sha256}
    else
      _error ->
        snooze_time = VtApiRateLimiter.get_snooze_time(priority)
        # Logger.warning("Snoozing job for #{sha256} because of VT rate limiting: #{snooze_time}")
        {:snooze, snooze_time}
    end
  end
end
