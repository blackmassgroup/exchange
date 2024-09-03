defmodule VExchange.ObanJobs.Vt.StatusCheckVt do
  @moduledoc """
  This module defines a worker for checking the status of a VirusTotal analysis.

  It is used to update or remove the Sample in the database once the analysis is completed.
  """
  @max_attempts 20
  use Oban.Worker, queue: :vt_api, max_attempts: @max_attempts

  alias VExchange.VtApiRateLimiter
  alias VExchange.Services.VirusTotal
  alias VExchange.Samples

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"task_id" => sha256, "priority" => priority, "analysis_id" => id}}) do
    with(
      {:ok, %{"attributes" => %{"status" => "completed"}}} <- VirusTotal.get_analysis(id),
      {:ok, %{"attributes" => attrs}} <- VirusTotal.get_sample(sha256)
    ) do
      Samples.process_vt_result(attrs)
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
