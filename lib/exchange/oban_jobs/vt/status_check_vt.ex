defmodule Exchange.ObanJobs.Vt.StatusCheckVt do
  @moduledoc """
  This module defines a worker for checking the status of a VirusTotal analysis.

  It is used to update or remove the Sample in the database once the analysis is completed.
  """
  @max_attempts 20
  use Oban.Worker, queue: :vt_api_uploads, max_attempts: @max_attempts

  alias Exchange.VtApi.VtApiRateLimiter
  alias Exchange.Services.VirusTotal
  alias Exchange.Samples
  alias Exchange.ObanJobs.Vt.PostComment

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"task_id" => sha256, "priority" => priority, "analysis_id" => id}}) do
    with(
      {:ok, %{"attributes" => %{"status" => "completed"}}} <- VirusTotal.get_analysis(id),
      {:ok, %{"attributes" => attrs}} <- VirusTotal.get_sample(sha256)
    ) do
      Map.put(attrs, "priority", priority)
      |> Samples.process_vt_result()
      |> case do
        {:ok, sample} ->
          {:ok, sample}

        {:rate_limited, priority} ->
          {:snooze, VtApiRateLimiter.get_snooze_time(priority)}

        {:error, :sample_not_found} ->
          {:ok, :sample_not_found}

        {:error, :error_updating_local_sample} ->
          {:ok, :error_updating}

        {:error, {:posting_comment, _}} ->
          %{
            "sha256" => sha256,
            "priority" => priority
          }
          |> PostComment.new()
          |> Oban.insert()

        {:error, :posting_comment} ->
          %{
            "sha256" => sha256,
            "priority" => priority
          }
          |> PostComment.new()
          |> Oban.insert()

        error ->
          error
      end
    else
      _ ->
        {:snooze, VtApiRateLimiter.get_snooze_time(priority)}
    end
  end

  @doc """
  This function is called when the job is backing off due to a failure or when the job is snoozed.

  It corrects the attempt count based on the current attempt and the maximum attempts because
  we do not have the "Oban Pro" package.

  https://hexdocs.pm/oban/Oban.Worker.html#module-snoozing-jobs
  """
  @impl Oban.Worker
  def backoff(%Oban.Job{} = job) do
    corrected_attempt = @max_attempts - (job.max_attempts - job.attempt)
    Oban.Worker.backoff(%{job | attempt: corrected_attempt})
  end

  def new(args, opts \\ []) do
    super(args, Keyword.put(opts, :priority, args["priority"]))
  end
end
