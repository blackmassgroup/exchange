defmodule VxUnderground.ObanJobs.TriageUpload do
  alias VxUndergroundWeb.SampleChannel
  alias VxUnderground.Services.S3

  use Oban.Worker,
    queue: :default,
    priority: 1,
    max_attempts: 2,
    unique: [period: 60]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"sample" => sample}}) do
    with(
      {:ok, presigned_url} <-
        ExAws.Config.new(:s3)
        |> ExAws.S3.presigned_url(:get, S3.get_bucket(), "#{sample["sha256"]}"),
      {:ok, triage_resp} <- VxUnderground.Services.Triage.upload(presigned_url),
      {:ok, _hashes} <- VxUnderground.Services.Triage.get_sample(triage_resp["id"])
    ) do
      SampleChannel.broadcast("triage_report_complete", %{sample: sample})

      :ok
    else
      msg -> {:error, msg}
    end
  end
end
