defmodule VExchange.ObanJobs.CleanSamples do
  @max_attempts 20
  use Oban.Worker, queue: :clean_samples, max_attempts: @max_attempts
  alias VExchange.Samples
  alias VExchange.Services.S3

  def perform(%Oban.Job{args: %{"sha256" => sha256, "sample_id" => sample_id}}) do
    with {:ok, %{body: body}} <- S3.get_file_binary(sha256),
         true <- String.starts_with?(body, "--"),
         cleaned_binary <- clean_file(body),
         {:ok, _sample} <- Samples.create_from_binary(%{"file" => cleaned_binary}, 516),
         %{id: _} = sample <- Samples.get_sample(sample_id) do
      Samples.delete_sample(sample)
    else
      false ->
        {:ok, :clean_file}

      nil ->
        Samples.get_sample!(sample_id)
        |> Samples.delete_sample()

      {:ok, _sample} ->
        Samples.get_sample!(sample_id)
        |> Samples.delete_sample()

      {:error, :duplicate} ->
        Samples.get_sample!(sample_id)
        |> Samples.delete_sample()

      {:error, {:http_error, 404, _}} ->
        Samples.get_sample!(sample_id)
        |> Samples.delete_sample()

      {:error, _} = error ->
        error
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
