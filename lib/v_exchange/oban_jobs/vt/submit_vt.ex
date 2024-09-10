defmodule VExchange.ObanJobs.Vt.SubmitVt do
  @moduledoc """
  This module defines a worker for submitting files to VirusTotal.

  It is used to submit files to VirusTotal and update the Sample in the database accordingly.

  The four different priorities are:
    - 0: New Uploads (2nd request)
    - 1: New Uploads (1st request)
    - 2: Backlog (2nd request)
    - 3: Backlog (1st request)

    It was designed like this because the backlog is 25 million and we want to
    prioritize new uploads over backlog items.


  ## Usage

    To enqueue a job, you can use the `Oban.insert/2` function:
          %{
            "sha256" => sha256,
            "priority" => 0
          }
          |> VExchange.ObanJobs.Vt.SubmitVt.new()
          |> Oban.insert()

  """
  @max_attempts 20
  use Oban.Worker, queue: :vt_api, max_attempts: @max_attempts
  require Logger
  alias VExchange.Services.VirusTotal
  alias VExchange.VtApi.VtApiRateLimiter
  alias VExchange.Services.S3
  alias VExchange.Samples
  alias VExchange.ObanJobs.Vt.StatusCheckVt

  @doc """
  This function is called when the job is enqueued.

  It sets the priority of the job based on the attributes of the job.
  """
  def new(args, opts \\ []) do
    args = Map.put(args, "priority", get_priority(args))
    super(args, Keyword.put(opts, :priority, args["priority"]))
  end

  # This function returns the priority of the job based on the attributes of the job.

  defp get_priority(%{"is_new" => true, "is_first_request" => false}), do: 0
  defp get_priority(%{"is_new" => true, "is_first_request" => true}), do: 1
  defp get_priority(%{"is_new" => false, "is_first_request" => false}), do: 2
  defp get_priority(%{"is_new" => false, "is_first_request" => true}), do: 3

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

  @doc """
  Performs the VirusTotal submission and analysis process for a given sample.

  This function handles the following steps:
  1. Checks if the request is allowed based on the priority.
  2. Attempts to retrieve the sample from VirusTotal.
  3. If the sample doesn't exist on VirusTotal, retrieves the binary from S3.
  4. Submits the binary to VirusTotal for processing.
  5. Schedules a status check job for the submitted analysis.

  If the sample already exists on VirusTotal, it updates the local sample data
  and posts a comment.

    ## Parameters
      - job: An `Oban.Job` struct containing the following args:
        - sha256: The SHA256 hash of the sample.
        - priority: The priority level of the job.

    ## Returns
      - `{:ok, sample}` if the sample already exists and is updated successfully.
      - `{:snooze, snooze_time}` if the job needs to be rescheduled due to rate limiting.
      - The result of `Oban.insert!/2` if a new status check job is scheduled.

    ## Errors
      - Returns `:error` if updating an existing sample fails.
      - Any error from the `with` clause will result in a snooze.

    ## Notes
      - Uses `VtApiRateLimiter` to manage API request rates.
      - Interacts with `VirusTotal`, `S3`, and `Samples` modules.
      - Creates a new `StatusCheckVt` job for submitted samples.

    ## Usage

      To enqueue a job, you can use the `Oban.insert/2` function:
          %{
            "sha256" => sha256,
            "priority" => 0
          }
          |> VExchange.ObanJobs.Vt.SubmitVt.new()
          |> Oban.insert()
  """
  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"sha256" => sha256, "priority" => priority} = _args} = _job) do
    with(
      {:error, :does_not_exist} <- VirusTotal.get_sample(sha256),
      {:ok, %{body: binary}} <- S3.get_file_binary(sha256),
      :ok <- VtApiRateLimiter.allow_request(priority),
      {:ok, %{"type" => "analysis", "id" => id}} <- VirusTotal.submit_for_processing(binary)
    ) do
      job =
        %{
          "task_id" => sha256,
          "analysis_id" => id,
          "priority" => max(priority - 1, 0)
        }
        |> StatusCheckVt.new()
        |> Oban.insert!(scheduled_at: DateTime.add(DateTime.utc_now(), 60))

      {:ok, job}
    else
      {:ok, %{"attributes" => %{"last_analysis_results" => _} = attrs}} ->
        Samples.process_vt_result(attrs)

      _error ->
        snooze_time = VtApiRateLimiter.get_snooze_time(priority)
        Logger.warning("Snoozing job for #{sha256} because of VT rate limiting: #{snooze_time}")
        {:snooze, snooze_time}
    end
  end
end
