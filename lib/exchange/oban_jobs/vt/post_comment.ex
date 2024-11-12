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
  alias Exchange.ObanJobs.Vt.SubmitVt
  alias Phoenix.PubSub

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"sha256" => sha256, "priority" => priority} = _args}) do
    with(
      :ok <- VtApiRateLimiter.allow_request(priority),
      {:ok, %{"attributes" => %{"last_analysis_results" => _} = attrs}} <-
        VirusTotal.get_sample(sha256),
      true <- VirusTotal.is_malware?(attrs),
      comment <- Samples.get_comment(),
      {:ok, _} <- VirusTotal.post_file_comment(sha256, comment)
    ) do
      {:ok, sha256}
    else
      {:rate_limited, priority} ->
        {:snooze, VtApiRateLimiter.get_snooze_time(priority)}

      {:error, :does_not_exist} ->
        SubmitVt.new(%{"sha256" => sha256, "is_new" => true, "is_first_request" => true})
        |> Oban.insert()

      false ->
        sample = Samples.get_sample_by_sha256(sha256)

        new_attrs = %{
          tags: ["marked-non-malware"] ++ ((sample && sample.tags) || [])
        }

        with(
          {:ok, _} <- CleanHashes.create_clean_hash(%{sha256: sample.sha256}),
          {:ok, sample} = result <- Samples.update_sample(sample, new_attrs)
        ) do
          if Application.get_env(:exchange, :env) != :test do
            # S3.delete_exchange_object(sample.sha256)
            PubSub.broadcast(Exchange.PubSub, "samples", {:updated_sample, sample})
          end

          result
        else
          _ -> :ok
        end

      _error ->
        snooze_time = VtApiRateLimiter.get_snooze_time(priority)
        # Logger.warning("Snoozing job for #{sha256} because of VT rate limiting: #{snooze_time}")
        {:snooze, snooze_time}
    end
  end
end
