defmodule VExchange.ObanJobs.CleanSamples do
  @max_attempts 20
  use Oban.Worker, queue: :clean_samples, max_attempts: @max_attempts
  alias VExchange.MalformedSamples

  def perform(%Oban.Job{args: %{"sha256" => sha256}}) do
    # Step 1: Check if the file is malformed
    # with {:ok, %{body: body}} <- VExchange.Services.S3.get_file_binary(sha256),
    #      true <-
    #        String.contains?(body, ~S(name=\"file\";)) or
    #          String.contains?(body, "Content-Disposition: form-data;") or
    #          String.contains?(body, ~S("file\":)) do
    #   VExchange.MalformedSamples.create_malformed_sample(%{sha256: sha256})
    # end

    # Step 2: Clean the file
    with {:ok, %{body: body}} <- VExchange.Services.S3.get_file_binary(sha256),
         cleaned_binary <- clean_file(body) do
      VExchange.Samples.create_from_binary(%{"file" => cleaned_binary}, 516)
      |> case do
        {:ok, sample} ->
          MalformedSamples.get_malformed_sample_by_sha(sample.sha256)
          |> MalformedSamples.delete_malformed_sample()

        error ->
          error
      end
    end
  end

  def clean_file(binary) when is_binary(binary) do
    binary
    |> remove_starting_boundary()
    |> remove_ending_boundary()
  end

  defp remove_starting_boundary(binary) do
    case :binary.split(binary, "\r\n\r\n") do
      [_header, content | _] -> content
      # Return original if pattern doesn't match
      _ -> binary
    end
  end

  defp remove_ending_boundary(binary) do
    case :binary.split(binary, "\r\n--") do
      [content, _footer] -> content
      # Return original if pattern doesn't match
      _ -> binary
    end
  end
end
