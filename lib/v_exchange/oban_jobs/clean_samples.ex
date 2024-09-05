defmodule VExchange.ObanJobs.CleanSamples do
  @max_attempts 20
  use Oban.Worker, queue: :clean_samples, max_attempts: @max_attempts

  def perform(%Oban.Job{args: %{"sha256" => sha256}}) do
    # For all samples in database
    with {:ok, %{body: body}} <- VExchange.Services.S3.get_file_binary(sha256),
         true <-
           String.contains?(body, ~S(name=\"file\";)) or
             String.contains?(body, "Content-Disposition: form-data;") or
             String.contains?(body, ~S("file\":)) do
      VExchange.MalformedSamples.create_malformed_sample(%{sha256: sha256})
    end
  end
end
